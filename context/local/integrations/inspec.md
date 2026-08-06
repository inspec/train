# InSpec's Use of the Train Framework & Plugin System

> Scope: a thorough, critical assessment of how **Chef InSpec** consumes **Train** — the
> transport interface — and how the two projects' plugin systems relate. Grounded in the
> `inspec/inspec` source (`context/reference-repos/inspec`, `train ~> 3.16`) and the Train
> source in this repo. Companion to [`../design/plugins-v1.md`](../design/plugins-v1.md)
> (the Train V1 plugin API) and
> [`chef-infra-client-agentless.md`](./chef-infra-client-agentless.md) (Chef's parallel use of
> Train). Written as baseline material for a future Train plugin-API redesign.

## Contents

1. [Executive summary](#1-executive-summary)
2. [Dependency & version surface](#2-dependency--version-surface)
3. [The two plugin systems (and why InSpec has no "transport" plugin type)](#3-the-two-plugin-systems)
4. [Target resolution & credentials](#4-target-resolution--credentials)
5. [Backend construction & caching](#5-backend-construction--caching)
6. [The `Inspec::Backend` wrapper](#6-the-inspecbackend-wrapper)
7. [Resources → Train primitives](#7-resources--train-primitives)
8. [Platform detection & schema export](#8-platform-detection--schema-export)
9. [Testing via the Mock transport](#9-testing-via-the-mock-transport)
10. [Critical assessment](#10-critical-assessment)
11. [Cross-references & sources](#11-cross-references--sources)

---

## 1. Executive summary

InSpec is, at its core, a **DSL and runner layered directly on top of Train**. Every audit
resource ultimately reaches its target through exactly three Train primitives —
`run_command`, `file`, and `platform` (plus an occasional `hostname` and `.class` check).
Train supplies *connectivity and platform identity*; InSpec supplies *resources, controls,
reporting, and a CLI*.

![InSpec over Train — architecture](img/inspec-train-architecture.png)

Three things stand out and drive the rest of this document:

1. **The coupling is narrow but deep.** InSpec touches only a tiny slice of Train's
   `BaseConnection` god-object API, yet it is *totally* dependent on it — there is no
   abstraction seam or adapter; resources call `inspec.backend.run_command(...)` directly and
   rescue `Train::` exception classes by name.
2. **There are two separate plugin systems.** InSpec's own Plugin v2 (`Inspec.plugin(2)`) has
   plugin *types* for CLI/DSL/input/reporter/resource-pack/mock — but **not for transports**.
   Transports live entirely in Train's v1 plugin system (`Train.plugin(1)`). InSpec only
   *bridges* to Train's registry to recognize and install `train-*` gems.
3. **The Mock transport is a first-class citizen of InSpec's core.** Not just tests — the
   resource base class special-cases `Train::Transports::Mock::Connection` to bypass its
   platform-support gate. Train's test double is wired into InSpec's production code path.

## 2. Dependency & version surface

From the gemspecs:

| Gem | Declares | Notes |
|---|---|---|
| `inspec-core` | `train-core ~> 3.16, >= 3.16.5` | the slim transport core |
| `inspec` | `train ~> 3.16, >= 3.16.5` | full Train (adds ssh/winrm helpers etc.) |
| `inspec` | `train-habitat ~> 0.1`, `train-aws ~> 0.2`, `train-winrm ~> 0.4.0`, `train-kubernetes >= 0.3.1` | "Train plugins we ship with InSpec" |

Observations:

- **Tight major-version pin to Train 3.x.** InSpec rides Train's 3.16 line closely; a Train
  major bump (e.g. a V2 plugin API) is an InSpec-breaking event by construction.
- **Transport gems are split across two homes.** Train *core* bundles `local, ssh, docker,
  podman, mock, azure, gcp, vmware, cisco_ios`; the *external* transports InSpec ships as
  direct deps are `train-winrm, train-aws, train-kubernetes, train-habitat` (and, in the
  Chef ecosystem, `train-rest` — now at `prospectra/train-rest`). See
  [`../design/plugins-v1.md` §12](../design/plugins-v1.md#12-real-world-patterns--variances)
  for the archetypes.
- **InSpec never `require`s the transport gems itself.** There is no `require "train-aws"`
  anywhere in `lib/`. InSpec relies entirely on Train's `load_transport` fallback
  (`require "train-<name>"`) when `Train.create(name)` is first called. The gemspec deps only
  guarantee the gems are *installed*; Train decides *when* to load them.

## 3. The two plugin systems

This is the single most important structural fact for a redesign.

**InSpec Plugin v2** (`lib/inspec/plugin/v2/`) registers plugin *types* via
`register_plugin_type`, and the shipped types are:

```
cli · dsl (input / resource_dsl) · mock · reporter · streaming_reporter · resource_pack
```

There is **no `transport` plugin type**. InSpec deliberately does not own transports — it
delegates 100% of connectivity to Train's own, older, entirely separate v1 plugin system
(`Train.plugin(1)`, `Train::Plugins.registry`, keyed on Strings).

The only coupling between the systems is a **registry bridge** used for *management*, not
*runtime dispatch*:

```ruby
# lib/inspec/plugin/v2/registry.rb
def loaded_plugin?(name)
  # HACK: ... unless it is a train plugin; then the Train::Registry is the source of truth.
  return registry.dig(name.to_sym, :loaded) unless name.to_s.start_with?("train-")
  Train::Plugins.registry.key?(name.to_s.sub(/^train-/, ""))
end
```

And the `inspec plugin install` command probe-loads a candidate gem and, if its name starts
with `train`, verifies it registered itself into **Train's** registry (not InSpec's):

```ruby
# inspec-plugin-manager-cli/cli_command.rb
if plugin_name.to_s.start_with?("train")
  registry_key = plugin_name.to_s.sub(/^train-/, "")
  unless Train::Plugins.registry.key?(registry_key)
    ui.red("... Ensure something inherits from 'Train.plugin(1)' - installation failed.")
  end
end
```

So a `train-*` gem is a **second-class, specially-cased citizen** of InSpec's plugin manager:
InSpec can *install* it and *report* it as loaded, but it is owned, loaded, and dispatched by
Train. The `train-`/`inspec-` gem-name prefix is load-bearing — it is how InSpec decides which
registry to consult. (This is exactly the `inspec-`-vs-`train-` distinction analyzed in
[`../design/plugins-v1.md` §12.5](../design/plugins-v1.md#125-gcp--in-core-api-only-transport).)

## 4. Target resolution & credentials

All target/credential handling lives in `Inspec::Config#unpack_train_credentials`
(`lib/inspec/config.rb`) and produces the symbol-keyed hash Train expects.

![Connect sequence](img/inspec-train-connect-sequence.png)

The pipeline:

1. **Determine the backend** (`_utc_determine_backend`). No `--target` ⇒ `backend = "local"`.
   Otherwise the transport name is parsed from the URI scheme with a strict regex
   `^(?<transport_name>[a-z_\-0-9]+)://` — a bare hostname with no `scheme://` is a hard error.
2. **Resolve a credential set** (`_utc_merge_credset`). InSpec implements **RFC-099**
   credentials files: `-t winrm://prod` looks up `credentials → winrm → prod` in the config
   file. If there is no credset match, it falls back to
   `Train.unpack_target_from_uri(target)` — i.e. Train parses `scheme://user:pass@host:port`.
3. **Filter & un-prefix transport options** (`_utc_merge_transport_options`). InSpec asks
   Train which options a transport accepts and copies the matching CLI flags in:

   ```ruby
   transport_options = Train.options(transport_name).keys.map(&:to_s)
   ```

4. **Symbolize keys** so they match Train's `option :name` declarations.

**This is the identical mechanism Chef Target Mode uses** (`Train.options(protocol)` filtering);
see [`chef-infra-client-agentless.md` §4](./chef-infra-client-agentless.md). `Train.options`
is effectively a *public contract* two major consumers depend on for config marshalling.

**Leaky abstraction — InSpec's CLI hardcodes transport-specific flags.** `base_cli.rb` defines
`--host`, `--sudo`/`--sudo_password`/`--sudo_command`, `--key_files`, `--ssl`,
`--winrm_transport`, `--winrm_shell_type`, `--winrm_disable_sspi`, `--ssh_config_file`, etc.
The "uniform" transport layer is not uniform at the UI: InSpec must know SSH- and WinRM-specific
option names, and `Train.options()` is the only thing keeping them loosely coupled. A new
transport with novel options cannot be fully driven from the InSpec CLI without InSpec changes
(unless the user drops to `-t scheme://…` URI form or a credentials file).

## 5. Backend construction & caching

`Inspec::Backend.create(config)` (`lib/inspec/backend.rb`) is the sole runtime entry point:

```ruby
train_credentials = config.unpack_train_credentials
transport_name    = Train.validate_backend(train_credentials)
transport         = Train.create(transport_name, train_credentials)
connection        = transport.connection
# caching policy...
Inspec::Backend.new(connection)
```

Notable details:

- **Caching is InSpec's decision, applied to Train.** With `--backend-cache` (or *always* for
  the Mock transport), InSpec calls `connection.enable_cache(:file)` and
  `enable_cache(:command)`; otherwise it disables both. InSpec reaches directly into Train's
  caching switches — another point where the god-object's internals are part of the contract.
- **Error mapping.** `Train::ClientError`, `Train::TransportError`, and `Errno::ENOENT` are
  rescued and rewritten into human "can't connect to '<name>' backend" strings. InSpec depends
  on Train's exception taxonomy by class name.
- **`Train.validate_backend`** is trusted to normalize/resolve the backend name (including the
  `local`-vs-explicit logic) before `create`.

## 6. The `Inspec::Backend` wrapper

`Inspec::Backend` is a thin façade around a single Train connection:

- `#backend` → the raw Train connection. In a resource, `inspec.backend` **is** this Train
  connection object, so resources call Train's connection API directly.
- `add_resource_methods` dynamically defines one method per registered resource, and
  `method_missing` routes unknown names through the resource DSL — so `inspec.file(...)`,
  `inspec.command(...)` etc. resolve to resources, while `inspec.backend.file(...)` reaches
  Train.
- `local_transport?` = `backend.is_a?(Train::Transports::Local::Connection)` — a **hard
  `is_a?` check on a specific Train class**, used by resources that want a Ruby-stdlib fast
  path (only the `http` resource actually uses it today).
- `version` exposes the InSpec version; `inspect` prints `@transport=<connection class>`.

The wrapper adds almost no abstraction: it does not hide Train's API, normalize its data, or
insulate resources from Train class names. It is a convenience holder, not an adapter.

## 7. Resources → Train primitives

![Resource dispatch](img/inspec-train-resource-dispatch.png)

Across all bundled resources, the entire Train runtime surface InSpec uses is:

| Call | Count* | Consumers |
|---|---|---|
| `inspec.backend.run_command` | ~6 direct (+ every shell-based resource via `command`) | `command`, `bash`, `powershell`, `script`, … |
| `inspec.backend.file` | 2 direct (+ every file-based resource via `file`) | `file`, `directory`, config-file resources |
| `inspec.backend.platform` | 1 | `platform`/`os` resources, `supports` gate |
| `inspec.backend.hostname` | 1 | `hostname` resource |
| `inspec.backend.class` / `respond_to?` | few | local/mock detection, diagnostics |

<sub>*direct call sites in `lib/inspec/resources`; most resources compose the `command`/`file`
resources rather than calling Train themselves.</sub>

Representative seams:

- **`command` resource** calls `inspec.backend.run_command(@command, timeout: @timeout)` and
  **rescues `Train::CommandTimeoutReached`** to raise an InSpec `ResourceFailed`. The timeout
  contract (and its quirky "sleep 0.1 so the connection isn't broken") is Train-specific
  knowledge living in an InSpec resource.
- **`file` resource** wraps `inspec.backend.file(path)` and surfaces Train's file-object
  metadata (content, mode, owner, …) as InSpec matchers. The data contract is Train's
  `Train::File::*` object (see [`plugins-v1.md` §7](../design/plugins-v1.md#7-data-contracts)).
- **`os`/`platform` resources** expose `inspec.backend.platform` fields (`family`, `release`,
  `arch`, `name`, `family_hierarchy`) and delegate matchers like `redhat?`, `linux?`,
  `windows?` straight to Train's platform object.
- **`http` resource** is the exception that proves the rule: **Train has no HTTP primitive**,
  so the resource branches on `inspec.local_transport?` — running Ruby `Net::HTTP` locally, or
  shelling out to a remote worker otherwise. (Chef Target Mode hit the same gap and faked HTTP
  via curl/wget; see [`chef-infra-client-agentless.md` §7](./chef-infra-client-agentless.md).)

The `CommandResult = Struct.new(:stdout, :stderr, :exit_status)` contract is consumed verbatim
by InSpec matchers (`its('stdout')`, `its('exit_status')`).

## 8. Platform detection & schema export

InSpec does **not** implement OS detection — it reads whatever `connection.platform` returns
and builds its `supports`/`os` machinery on top:

- The resource base's `check_supported!` calls `inspec.platform.supported?(@supports)` and
  raises "Unsupported resource/backend combination" using `backend.platform.name`.
- **Schema/enum generation** literally boots a Mock connection and dumps Train's platform
  table into InSpec's JSON schema:

  ```ruby
  # lib/inspec/schema.rb & schema/output_schema.rb
  Train.create("mock").connection
  Train::Platforms.export
  ```

  So InSpec's *published output schema* embeds Train's platform taxonomy — a direct data
  dependency on Train's `Platforms` registry.

## 9. Testing via the Mock transport

Train's Mock transport is the backbone of InSpec's ~hundreds of resource unit tests, via
`test/helpers/mock_loader.rb`:

```ruby
@backend = Inspec::Backend.create(Inspec::Config.mock)   # backend == Mock::Connection
mock = @backend.backend
mock.mock_os(@platform)                                   # pick an emulated OS
# fixture files loaded through a REAL local connection, then handed to the mock:
local = Train.create("local", command_runner: :generic).connection
mock_files["/etc/passwd"] = local.file(fixture_path("passwd"))
```

`MockLoader::OPERATING_SYSTEMS` enumerates ~40 emulated platforms (centos5→8, ubuntu, windows
2016/2019/2025, aix, solaris, hpux, …) as `{name, family, release, arch}` hashes fed to
`mock_os`. Commands and files are pre-registered; the mock returns canned `CommandResult`s and
fixture-backed file objects.

**The coupling that matters: InSpec's *production* code knows about the Mock transport.**

```ruby
# lib/inspec/resource.rb#check_supported!
test_backend = defined?(Train::Transports::Mock::Connection) &&
               backend.backend.class == Train::Transports::Mock::Connection
unless supported || test_backend
  raise ArgumentError, "Unsupported resource/backend combination..."
end
```

The platform-support gate is **deliberately bypassed when the backend is Train's Mock
connection**. A test double from the transport library is referenced by class name inside a
core control-flow decision. It works, but it is a textbook leaky abstraction: the abstraction
(Train connection) leaks a specific concrete subclass into InSpec's business logic.

## 10. Critical assessment

Strengths:

- **Clean separation of concerns at the macro level.** InSpec = resources/DSL/runner/reporting;
  Train = connectivity/platform. The division is real and has let both evolve (Target Mode in
  Chef, resource packs in InSpec) on a shared substrate.
- **Small runtime surface.** Only `run_command`/`file`/`platform` are load-bearing, so in
  principle Train's contract to InSpec is tiny and stable.
- **Config marshalling is data-driven** via `Train.options(name)`, avoiding (most) hardcoded
  per-transport wiring in the resolver.

Weaknesses / risks a redesign should target:

1. **No adapter seam.** Resources call `inspec.backend.<primitive>` and rescue `Train::*`
   exceptions directly. There is no interface InSpec owns; a Train API change ripples into
   dozens of resources. The "tiny surface" is not *encapsulated*, just *small*.
2. **The god-object leaks.** InSpec pokes Train's caching switches (`enable_cache(:file)`),
   `is_a?(Train::Transports::Local::Connection)`, and `== Train::Transports::Mock::Connection`.
   These are internals-as-contract. A V2 API should expose *capabilities* (can-run-commands,
   can-read-files, is-local, is-mock) rather than concrete classes.
3. **Two plugin systems, one blurred boundary.** Newcomers cannot tell a `train-` transport
   plugin from an `inspec-` resource pack without knowing the prefix convention, and InSpec's
   plugin manager special-cases `train-*` by *string prefix*. A unified or explicitly-federated
   plugin model (with a real "transport provider" contract on the InSpec side) would remove the
   `HACK`-commented bridges.
4. **The abstraction isn't uniform at the edges.** No HTTP primitive (so `http` and Chef both
   improvise); CLI hardcodes SSH/WinRM/sudo flags; API-only transports (aws/gcp/azure) don't
   implement `run_command`/`file` at all, so resource packs built on them bypass the very
   primitives InSpec's core is organized around. The "one uniform target" promise frays for
   cloud/API targets.
5. **Mock-as-core.** Wiring `Train::Transports::Mock::Connection` into `check_supported!`
   couples product behavior to a test fixture. A redesign should let resources declare
   capability/support requirements that a mock can *satisfy* declaratively, instead of the core
   branching on the mock's class.
6. **Version lock-step.** `train ~> 3.16` plus by-class-name coupling makes Train and InSpec a
   de-facto single release train; a Train plugin-API V2 cannot land without a coordinated
   InSpec major.

Net: InSpec is a *well-behaved but intimate* consumer of Train. The relationship is healthy in
spirit (thin runner over a transport lib) but under-specified in contract — it leans on concrete
classes, exception taxonomy, cache internals, a test double, and a gem-name prefix convention
rather than on an explicit, versioned interface. Those are precisely the seams a V2 plugin API
should formalize.

## 11. Cross-references & sources

- Train V1 plugin API: [`../design/plugins-v1.md`](../design/plugins-v1.md) (esp. §5
  BaseConnection god-object, §7 data contracts, §12 real-world archetypes).
- Chef's parallel use of Train: [`chef-infra-client-agentless.md`](./chef-infra-client-agentless.md)
  (`Train.options` filtering, missing HTTP primitive, `/etc/passwd` "Courtesy of InSpec").
- InSpec sources (under `context/reference-repos/inspec/`):
  `lib/inspec/backend.rb`, `lib/inspec/config.rb` (`unpack_train_credentials`),
  `lib/inspec/runner.rb`, `lib/inspec/resource.rb` (`check_supported!`),
  `lib/inspec/resources/{command,file,os,platform,http}.rb`,
  `lib/inspec/plugin/v2/{registry,plugin_base}.rb`,
  `lib/plugins/inspec-plugin-manager-cli/.../cli_command.rb`,
  `lib/inspec/schema.rb`, `test/helpers/mock_loader.rb`, `inspec.gemspec`,
  `inspec-core.gemspec`.
- Shared context consulted:
  `context/shared/by-repo/inspec/inspec/interfaces/train-backends.md` (marked *INCOMPLETE*),
  `context/shared/by-product/inspec/specifications/resource-pack-backends.md`.
- Diagrams: `img/inspec-train-architecture.png`,
  `img/inspec-train-connect-sequence.png`, `img/inspec-train-resource-dispatch.png`
  (regen: `java -jar plantuml.jar -tpng -o .. src/*.puml` from `img/src/`).
