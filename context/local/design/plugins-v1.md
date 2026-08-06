# Train Plugin API — Version 1 (V1) Reference & Design Notes

> Scope: this document describes the **current, shipping Train Plugin API (V1)** — the only
> version Train actually supports today (`Train.plugin(1)`). It is written as the factual
> baseline for a future redesign of the plugin API. Everything here is grounded in the Train
> source tree and in five real transports: the teaching example
> `examples/plugins/train-local-rot13`, three production reference plugins under
> `context/reference-repos/` (`train-winrm`, `train-aws`, `train-kubernetes`), and the
> in-core `gcp` transport (`lib/train/transports/gcp.rb`).

## Contents

1. [Overview & scope](#1-overview--scope)
2. [Anatomy of a V1 plugin](#2-anatomy-of-a-v1-plugin)
3. [Registration & discovery/loading](#3-registration--discoveryloading)
4. [The Transport class](#4-the-transport-class)
5. [The Connection class (`BaseConnection`)](#5-the-connection-class-baseconnection)
6. [Platform & family declaration](#6-platform--family-declaration)
7. [Data contracts](#7-data-contracts)
8. [Options, target URIs & credentials](#8-options-target-uris--credentials)
9. [Runtime flow of `run_command` and `file`](#9-runtime-flow-of-run_command-and-file)
10. [Testing a plugin](#10-testing-a-plugin)
11. [Walkthrough: `train-local-rot13`](#11-walkthrough-train-local-rot13)
12. [Real-world patterns & variances](#12-real-world-patterns--variances)
13. [Limitations & observations (springboard for V2)](#13-limitations--observations-springboard-for-v2)

---

## 1. Overview & scope

Train is the **transport interface** underpinning Chef InSpec. It provides a *uniform* way
to talk to a target — a local machine, a remote host over SSH/WinRM, a container, or a cloud
API — exposing three primitive capabilities to callers:

- **Command execution** — `connection.run_command("...")` → a result with
  `stdout`/`stderr`/`exit_status`.
- **File access** — `connection.file("/path")` → a file object with a uniform metadata API.
- **Platform detection** — `connection.platform` (aliased `os`) → what the target *is*.

A **Train plugin** adds a new transport (a new "backend") to this system. Train itself has
no CLI and only a light test harness; plugins are normally exercised through InSpec, but they
can be developed and tested standalone (see [§10](#10-testing-a-plugin)).

> **Train plugin vs. InSpec plugin.** A *Train* plugin (this document) provides
> *connectivity*. An *InSpec* plugin (a different, "v2" plugin system) provides *resources*,
> CLI commands, reporters, etc. They use different factory calls, namespaces, and gem
> prefixes. InSpec resource packs (for example the GCP resource pack) are InSpec plugins that
> sit *on top of* a Train transport — they are **not** transports themselves.

![Component architecture](img/architecture.png)

## 2. Anatomy of a V1 plugin

A Train plugin is a Ruby **gem** named `train-<name>` with three logical components plus an
entry point:

| Component | Role | Base / form |
|---|---|---|
| **Entry point** | `lib/train-<name>.rb`; sets load path, requires the parts | plain file |
| **Transport** | glue: registers the plugin name, declares options, builds the Connection | `class < Train.plugin(1)` |
| **Connection** | does the real work (commands, files, API, caching) | `class < Train::Plugins::Transport::BaseConnection` |
| **Platform** | declares/detects the target platform & family | usually a `module` mixed into Connection |

Conventional gem layout (from `train-local-rot13`):

```
train-<name>/
├── train-<name>.gemspec        # gem name MUST start with "train-"
├── Gemfile
├── Rakefile                    # test + rubocop tasks
├── lib/
│   ├── train-<name>.rb         # entry point
│   └── train-<name>/
│       ├── version.rb          # VERSION constant, loaded cheaply by gemspec
│       ├── transport.rb
│       ├── connection.rb
│       └── platform.rb
└── test/
    ├── helper.rb               # require "train/plugin_test_helper"
    ├── unit/…                  # class-shape tests
    └── functional/…            # behavior via Train.create
```

The entry point should be minimal — set the load path, then require the pieces
(`lib/train-local-rot13.rb`):

```ruby
libdir = __dir__
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require "train-local-rot13/version"
require "train-local-rot13/transport"
require "train-local-rot13/platform"
require "train-local-rot13/connection"
```

Plugins are conventionally namespaced under `TrainPlugins::<CamelName>`.

## 3. Registration & discovery/loading

### The versioned base class

Everything hangs off `Train.plugin(version = 1)` (`lib/train/plugins.rb`). It returns the
class you inherit your Transport from, and it is the sole version gate:

```ruby
def self.plugin(version = 1)
  if version != 1
    raise ClientError, "Only understand train plugin version 1. ..."
  end
  ::Train::Plugins::Transport
end
```

> **There is only V1.** Any argument other than `1` raises. This is the concrete artifact a
> future "V2" would extend.

### The registry

`Train::Plugins.registry` is a plain `Hash` mapping **String** plugin names → Transport
classes. A plugin adds itself by calling the class-level `name` DSL inside its Transport
(`lib/train/plugins/transport.rb`):

```ruby
def self.name(name)
  Train::Plugins.registry[name] = self
end
```

Note the name is the transport scheme (`"winrm"`, `"aws"`, `"k8s"`, `"local-rot13"`), **not**
the gem name (`train-winrm`, …). Keys are Strings, not Symbols.

### Discovery / loading

`Train.create(name, *args)` (`lib/train.rb`) resolves a name to a class via
`load_transport`, then instantiates it. Resolution order:

1. **Registry hit** — return `registry[name]` if already loaded.
2. **Core transport** — `require "train/transports/<name>"` (built-ins like `ssh`, `local`,
   `docker`, `winrm`…).
3. **Gem convention** — `require "train-<name>"` (this is what loads external plugins; the
   entry point registers the name as a side effect of being required).
4. Otherwise raise `Train::PluginLoadError` ("Please install it first").

![Load & connect lifecycle](img/sequence-load-connect.png)

## 4. The Transport class

Minimal Transport (from `train-local-rot13`):

```ruby
module TrainPlugins
  module LocalRot13
    class Transport < Train.plugin(1)
      name "local-rot13"

      def connection(_instance_opts = nil)
        @connection ||= TrainPlugins::LocalRot13::Connection.new(@options)
      end
    end
  end
end
```

Responsibilities and available machinery:

- **`name "x"`** — required; registers the plugin.
- **`connection(_opts = nil)`** — the *only* method you must implement. Return a
  `BaseConnection` subclass instance. The base implementation raises `ClientError`. The
  argument is "undocumented and rarely used" (per the base class comments) — some plugins
  ignore it, WinRM uses it as mutable `state` (see [§12](#12-real-world-patterns--variances)).
- **`initialize(options = {})`** — the base stores `@options = merge_options({}, options)`
  and sets up `@logger`. If you override it, call `super`.
- **Options DSL** — `Train::Options` is attached to every Transport
  (`lib/train/options.rb`). At class level you get `option`, `default_options`,
  `include_options`; at instance level `merge_options`, `validate_options`. Declare options
  with defaults or a lazy block:

  ```ruby
  option :host, required: true
  option :port, default: 5985
  option(:region, required: true) { ENV["AWS_REGION"] }   # block = lazy default
  ```

  `merge_options` fills defaults (evaluating `Proc` defaults and `:coerce`), and also folds
  in the **audit-log options** (`enable_audit_log`, `audit_log_location`, …).
  `validate_options` enforces `required: true`.

## 5. The Connection class (`BaseConnection`)

`Train::Plugins::Transport::BaseConnection` (`lib/train/plugins/base_connection.rb`) is the
heart of the API. Its own comments admit it is overloaded: *"Later generations of the plugin
API will likely separate out these responsibilities."* Today one object handles auth,
platform detection, caching, file access, command execution, API execution, and JSON
marshalling.

![Class model](img/class-diagram.png)

### Public API (what callers use)

| Method | Purpose |
|---|---|
| `run_command(cmd, opts = {}, &data_handler)` | Execute a command (with caching + audit + arity dispatch). |
| `file(path, *args)` | Get a file object (with caching + audit). |
| `platform` / `os` | Detected platform (memoized `Train::Platforms::Detect.scan(self)`). |
| `upload(locals, remote)` / `download(remotes, local)` | File transfer (default impls use `file(...).content`). |
| `login_command` | Return a `LoginCommand` for an interactive session (default raises). |
| `wait_until_ready` | Block until the target is usable (default no-op). |
| `close` | Tear down (default no-op). |
| `enable_cache(type)` / `disable_cache(type)` | Toggle caching for `:file` / `:command` / `:api_call`. |
| `cached_client(type, key) { … }` | Memoize an expensive client under the cache. |
| `force_platform!(name, details = nil)` | Bypass detection and assert a platform (see [§6](#6-platform--family-declaration)). |
| `to_json` / `load_json` | Marshal cached file state (used by InSpec's mock/`--json-config`). |

### Methods you implement (the real contract)

These are **private** and raise `NotImplementedError` in the base — you override the ones
your transport supports:

```ruby
def run_command_via_connection(command, opts = {}, &data_handler); end
def file_via_connection(path, *args); end
```

- Implement **both** for a shell-style transport (winrm, k8s, rot13, local).
- Implement **neither** for a pure API transport (aws) — callers use plugin-specific
  accessors instead.
- The optional **`data_handler`** block lets a transport stream inbound data
  (`data_handler.call(chunk)`); implementations must call it explicitly or it's ignored.

### Caching

The base sets defaults `{ file: true, command: false, api_call: false }` and maintains
`@cache[type]`. `run_command`/`file` consult it (`@cache[type][key] ||= …`).
`enable_cache`/`disable_cache` validate the type against the known set (else
`Train::UnknownCacheType`). `cached_client` is a convenience for memoizing SDK clients.

### Arity-based dispatch (compatibility wart)

Because plugins are separate gems that can't all be updated in lockstep, `run_command`
inspects `method(:run_command_via_connection).arity` and calls the 1-arg or 2-arg form
accordingly. New plugins should use the 2-arg `(cmd, opts, &h)` form.

### Audit logging

If `enable_audit_log` is set, `run_command`/`file`/`upload` emit structured entries to a
`Train::AuditLog` created in the base initializer.

## 6. Platform & family declaration

Train has a full platform/family detection engine
(`lib/train/platforms/…`): a tree of platforms and families walked by `Scanner`
(`Detect.scan(backend)`), matching on files/uname/etc. Real OS transports (SSH, local,
WinRM's remote file class) rely on it.

Most *plugin* authors, however, know exactly what they connect to, so they **bypass
detection** with `force_platform!`. The idiom (a `Platform` module mixed into the
Connection) declares the platform's family membership, then forces it:

```ruby
module TrainPlugins::Aws
  module Platform
    def platform
      Train::Platforms.name("aws").in_family("cloud")
      force_platform!("aws", release: "train-aws: v#{VERSION}, aws-sdk-core: v#{sdk_ver}")
    end
  end
end
```

- `Train::Platforms.name(x).in_family(y)` registers the platform and its family.
- `force_platform!(name, details)` (in `BaseConnection`) sets the backend, builds the family
  hierarchy, and attaches platform helper methods — no scanning.
- **Family choice matters.** Cloud/API plugins declare the **`cloud`** family (aws, k8s). A
  filesystem-capable plugin declares an OS family (`unix`/`windows`) so InSpec's file logic
  works — rot13 declares *both* `unix` and `windows`.
- `release:` is a free-form version string — commonly the plugin version and/or the
  underlying SDK/API version.

## 7. Data contracts

### CommandResult

`run_command_via_connection` must return an object exposing `stdout`, `stderr`,
`exit_status`. Train ships `Train::Extras::CommandResult`
(`Struct.new(:stdout, :stderr, :exit_status)`), but any duck-typed object works — rot13
returns an `OpenStruct`, WinRM/k8s/local return `CommandResult`.

```ruby
CommandResult = Struct.new(:stdout, :stderr, :exit_status)   # lib/train/extras.rb
```

### File object

`file_via_connection` must return a `Train::File`-shaped object. The interface is defined by
`Train::File::DATA_FIELDS` (`lib/train/file.rb`):

```
exist? mode owner group uid gid content mtime size selinux_label path
```

Plugins usually **reuse** a built-in file class (`Train::File::Local::Unix`,
`Train::File::Remote::Windows`, `Train::File::Remote::Linux`) and optionally wrap/subclass it
to customize behavior (rot13 wraps and overrides `content`; k8s subclasses
`Remote::Linux`).

### LoginCommand

`LoginCommand = Struct.new(:command, :arguments)` — returned by `login_command` to describe
how to open an interactive session (e.g. WinRM builds `mstsc`/`rdesktop`/`open` invocations).

## 8. Options, target URIs & credentials

Callers usually specify a target as a URI. `Train.unpack_target_from_uri` /
`Train.target_config` (`lib/train.rb`) parse `scheme://user:password@host:port/path?query`
into the symbol-keyed options hash the Transport receives:

- `scheme` → `:backend` (selects the plugin name)
- `host`/`port`/`user`/`password`/`path` → matching keys
- `?query=values` → merged as additional options

Plugins then re-interpret these fields as they see fit inside `Connection#initialize`. For
example, `train-aws` treats the URI as `aws://<region>/<profile>`:

```ruby
options[:region] = options[:host] || options[:region]
options[:profile] = options[:path].sub(%r{^/}, "") if options[:path]
```

New transports are encouraged to use the `transport://credset` convention rather than
inventing bespoke field mappings.

## 9. Runtime flow of `run_command` and `file`

![run_command / file runtime flow](img/sequence-run-command.png)

For a command: audit-log (if enabled) → arity check → cache check → your
`run_command_via_connection` (which talks to the target and may transform output) →
`CommandResult`. For a file: audit-log → cache check (files cached by default) → your
`file_via_connection` → file object. Both memoize into `@cache[...]` when the relevant cache
type is enabled.

## 10. Testing a plugin

`require "train/plugin_test_helper"` (`lib/train/plugin_test_helper.rb`) loads Train,
`minitest/spec` + `minitest/autorun`, and mixes in `TrainPluginBaseHelper` /
`TrainPluginFunctionalHelper` which provide `let` helpers like `plugin_fixtures_path`,
`registry`, etc. A plugin's `test/helper.rb` is typically just:

```ruby
require "train/plugin_test_helper"
```

Two common layers (all references follow this):

- **Unit tests** assert *shape*: the transport is registered without the `train-` prefix, the
  Transport `< Train.plugin(1)`, it defines `connection`, and the Connection defines
  `file_via_connection` / `run_command_via_connection`.
- **Functional tests** assert *behavior* through the public entrypoint, e.g.
  `Train.create("local-rot13").connection.run_command("echo hello")`, and check the output.

The `Rakefile` wires a `test` task (unit + functional) and a `lint` (RuboCop) task that
reuses Train's own `.rubocop.yml` via `Train.src_root` (`lib/train/globals.rb`).

## 11. Walkthrough: `train-local-rot13`

The canonical teaching plugin (`examples/plugins/train-local-rot13`) is a *local* transport
that applies the ROT13 cipher to every file it reads and every command's stdout. It shows the
full skeleton with nothing extraneous:

- **Transport** (`transport.rb`) — `name "local-rot13"`; `connection` returns a memoized
  `Connection`.
- **Connection** (`connection.rb`) — `include`s the Platform module; implements
  `file_via_connection` by wrapping `Train::File::Local::Unix` in a `FileContentRotator`
  (which overrides `content` and `method_missing`-delegates the rest); implements
  `run_command_via_connection` with `Mixlib::ShellOut`, returning an `OpenStruct` with
  rot13'd stdout.
- **Platform** (`platform.rb`) — declares membership in both `unix` and `windows`, then
  `force_platform!("local-rot13", release: VERSION)`.
- **Support** — `file_content_rotator.rb` (has-a `Train::File`, meddles with `content`),
  `version.rb`.

It's a deliberately "honest" plugin: it implements both capabilities and reuses Train's
file/command machinery. The production references each diverge from this baseline in
instructive ways.

## 12. Real-world patterns & variances

Four production transports show how plugins are *actually* built: three references under
`context/reference-repos/` (`train-winrm`, `train-aws`, `train-kubernetes`) plus the in-core
`gcp` transport (`lib/train/transports/gcp.rb`). `train-winrm` is the traditional case; the
other three "cheat" — two are API-only (no command/file access) and one shells out for a
"remote."

![Real-world archetypes](img/archetypes.png)

### 12.1 Comparison matrix

| Aspect | train-winrm | train-aws | train-kubernetes | gcp (in-core) |
|---|---|---|---|---|
| Kind | **Train plugin** (remote protocol) | **Train plugin** (API-only) | **Train plugin** (hybrid) | **Train transport** (API-only, **in train core**) |
| Base class | `Train.plugin(1)` | `Train.plugin(1)` | `Train.plugin(1)` | `Train.plugin(1)` |
| Namespace | `TrainPlugins::WinRM` | `TrainPlugins::Aws` | `TrainPlugins::TrainKubernetes` | `Train::Transports::Gcp` |
| Gem prefix | `train-` | `train-` | `train-` | — (ships in `train-core`) |
| `run_command_via_connection` | ✅ threaded, timeout | ❌ | ✅ via `kubectl exec` | ❌ |
| `file_via_connection` | ✅ `Remote::Windows` | ❌ | ✅ custom `File::Linux` | ❌ |
| `upload`/`download` | ✅ `WinRM::FS` | ❌ | ❌ | ❌ |
| Options DSL | very rich (~25) | few, ENV-lazy | few, ENV default | few, ENV-lazy (3) |
| Caching | default | forces `:api_call` | default | forces `:api_call` |
| Platform / family | OS (remote windows) | `force_platform!("aws")`, `cloud` | `force_platform!("k8s")`, `cloud` | `force_platform!("gcp")`, `cloud` |
| Connection reuse | ✅ `connection(state, &block)` | memoized | on init (`connect`) | memoized (`@connection ||=`) |
| Lazy dependency load | ✅ `load_needed_dependencies!` | eager `require` | eager `require` | eager `require` (`google-apis-*`) |
| Custom accessors | — | `aws_client` / `aws_resource` | `client`, `KubectlClient` | `gcp_client(klass)` + `gcp_*_client` |
| "Cheat" | (none — canonical) | no files/commands | shells out for a "remote" | no files/commands; bundled in core (no gem) |

### 12.2 train-winrm — the traditional/canonical case

Everything the API offers, used properly:

- **Rich options** (`option :host, required: true`, ssl/kerberos/socks/…) plus a
  **`validate_options` override** that normalizes symbols, computes the `endpoint`, and
  auto-detects the Kerberos realm from `/etc/krb5.conf`.
- **Connection reuse via the `connection` argument**: `connection(state = nil, &block)`
  merges `state` over options, and reuses the cached connection when the computed
  `connection_options` are unchanged, otherwise `create_new_connection` (closing the old
  one). This is the one real user of the "undocumented" `connection` argument.
- **Lazy dependency activation** — `load_needed_dependencies!` → `load_dependency` uses
  `gem`/`require` with a friendly `LoadError`→`Train::UserError` message telling the user
  what to `gem install`.
- **Full capability set** — `run_command_via_connection` runs in a `Thread` to support
  timeouts (raising `Train::CommandTimeoutReached`); `file_via_connection` →
  `Train::File::Remote::Windows`; `upload`/`download` via `WinRM::FS::FileManager`;
  `wait_until_ready` pings; `login_command` builds per-OS RDP commands; `close` tears down
  the session; `to_s` hides the password.
- **Runtime monkeypatch** — `socks_proxy_patch.rb` patches `HTTPClient` when a SOCKS proxy is
  configured — an escape hatch used because the API has no first-class proxy concept.

### 12.3 train-aws — API-only

- Implements **neither** `run_command_via_connection` nor `file_via_connection`. Instead it
  exposes **`aws_client(klass)`** (memoized under `:api_call` cache) and **`aws_resource`**;
  resource packs built on top call these.
- **Forces `enable_cache :api_call`** in the initializer so repeated client construction is
  cheap.
- **ENV-lazy option defaults** via the block form (`option(:region) { ENV["AWS_REGION"] }`)
  so tests can override the environment; it also maps the URI (`aws://region/profile`) into
  options and *writes back* to `ENV` for the SDK.
- **Platform**: `Train::Platforms.name("aws").in_family("cloud")` +
  `force_platform!`, with `release:` combining the plugin and `aws-sdk-core` versions.
- `unique_identifier` returns the AWS account id (via STS) — a convention some cloud plugins
  use to identify the target.
- Pulls in a large fan of `aws-sdk-*` gems as dependencies.

### 12.4 train-kubernetes — hybrid API + shell

- **Both worlds**: it holds a real API client (`K8s::Client` from `k8s-ruby`, built in
  `parse_kubeconfig`/`connect`) *and* executes commands by **shelling out to `kubectl exec`**
  (`KubectlClient` + `Mixlib::ShellOut`) — the "cheat": a "remote" command transport that is
  really a local `kubectl` subprocess.
- **Custom File subclass**: `File::Linux < Train::File::Remote::Linux` implements
  `content`/`exist?`/`content=`/… by running remote commands (`cat`, `test -e`, base64
  round-trips) through the connection.
- **Per-call options threading**: both `run_command_via_connection(cmd, opts = {})` and
  `file_via_connection(path, **args)` pass `pod`/`namespace`/`container` through on each call,
  because a single connection can target many pods. This exercises the `*args`/`opts`
  flexibility of the base API.
- **Platform**: `force_platform!("k8s")` in the `cloud` family.

### 12.5 gcp — in-core, API-only transport

Unlike the other three, the GCP transport is **not a separate gem** — it ships **inside train
core** at [`lib/train/transports/gcp.rb`](../../../lib/train/transports/gcp.rb)
(`class Gcp < Train.plugin(1)`, `name "gcp"`), alongside its sibling `azure`. Structurally it
is the closest twin of `train-aws`:

- **API-only** — implements neither `run_command_via_connection` nor `file_via_connection`.
  Instead it exposes client accessors: `gcp_client(klass)` (memoized under the `:api_call`
  cache) plus conveniences `gcp_compute_client`, `gcp_iam_client`, `gcp_project_client`,
  `gcp_storage_client`, `gcp_admin_client`.
- **Forces `@cache_enabled[:api_call] = true`** in the initializer, exactly like aws/azure.
- **ENV-lazy options** — `google_application_credentials`, `google_cloud_project`,
  `google_super_admin_email`, each defaulting from the matching env var via the `option { … }`
  block form; `connect` writes them back to `ENV` for the Google SDK and sets up
  application-default credentials.
- **Platform** — `force_platform!("gcp")`; the `gcp` platform is registered
  `in_family("cloud")` (`lib/train/platforms/detect/specifications/api.rb`). `release:` is
  derived from the installed `google-apis-core` gem version.
- **Eager dependencies** — the file `require`s the `google-apis-*` client gems at load time
  (no lazy activation like winrm).
- `unique_identifier` derives an id from the auth `client_id`/`issuer`.

**There is no `train-gcp` gem.** The `gcp://` backend has always lived in train core (added in
commit `d991228`, #283; `gcp_admin_client` in `c502811`, #349) — there is no separate
`train-gcp` gem on RubyGems nor an `inspec/train-gcp` repo. The InSpec **GCP resource pack**
consumes this transport via `inspec.backend` (calling `gcp_client` / `gcp_compute_client`
etc.). A code comment in that resource pack ("…will be moved into the `train-gcp` plugin
itself") refers to an extraction that never happened.

### 12.6 Recurring idioms across the references

- URI → options remapping inside `Connection#initialize` (aws, k8s).
- ENV-lazy option defaults via the `option { … }` block form (aws, gcp).
- `force_platform!` + explicit `in_family(...)` instead of detection (aws, k8s, gcp, rot13).
- Custom `*_client` / client accessors for API transports (aws `aws_client`, k8s `client`,
  gcp `gcp_client`).
- Per-call option threading through `run_command_via_connection` / `file_via_connection`
  (k8s).
- Reusing/subclassing built-in `Train::File::*` classes rather than reimplementing files
  (all file-capable plugins).
- Lazy gem activation with friendly errors (winrm); runtime monkeypatching as an escape hatch
  (winrm socks).
- Connection reuse driven by the (otherwise undocumented) `connection` argument (winrm).

## 13. Limitations & observations (springboard for V2)

Distilled from the code and the real-world variances above — the pain points a new API
version should address:

1. **`BaseConnection` is a god-object.** One class owns auth, platform detection, caching,
   files, commands, API execution, and JSON marshalling. The base class comments themselves
   anticipate splitting these responsibilities. Capability should be composable, not
   all-or-nothing on one base class.
2. **Capabilities are implicit and unenforced.** Whether a plugin supports commands and/or
   files is expressed only by *which private methods you happen to override*. There is no
   declaration of capabilities, so callers can't ask "does this transport support files?"
   without probing (aws implements neither; k8s fakes commands).
3. **Arity-based dispatch** in `run_command` is a compatibility hack for un-versioned plugin
   method signatures — a symptom of having no per-method versioning.
4. **The `connection` argument is undocumented** yet load-bearing (winrm uses it for reuse).
   Its semantics vary per plugin.
5. **File/command coupling to OS classes.** Reusing `Train::File::*` is powerful but leaks OS
   assumptions into API/cloud plugins; the `cloud` family + OS-family fudging (rot13 claims
   both `unix` and `windows`) is a workaround.
6. **No load-on-demand / capability activation** on the Train side. Plugins `require` heavy
   SDKs eagerly (aws pulls dozens of gems); the InSpec v2 side has an activator model Train
   lacks. WinRM hand-rolls `load_needed_dependencies!` to compensate.
7. **Single version only.** `Train.plugin(1)` hard-rejects any other version; there is no
   forward-compatible negotiation, so a V2 must be introduced carefully.
8. **Transport vs. resource-pack confusion.** The ecosystem mixes `train-*` transports and
   `inspec-*` resource packs (gcp); clearer separation / documentation of the boundary would
   help.

---

### Appendix: source references

- Core: `lib/train.rb`, `lib/train/plugins.rb`, `lib/train/plugins/transport.rb`,
  `lib/train/plugins/base_connection.rb`, `lib/train/options.rb`, `lib/train/extras.rb`,
  `lib/train/file.rb`, `lib/train/platforms/**`, `lib/train/plugin_test_helper.rb`,
  `lib/train/globals.rb`.
- Teaching example: `examples/plugins/train-local-rot13/**`.
- References: `context/reference-repos/{train-winrm,train-aws,train-kubernetes}/**` and
  `lib/train/transports/gcp.rb`.
- InSpec v2 plugin API (contrast): `context/reference-repos/inspec/dev-docs/plugins.md`.
- Diagram sources: `img/src/*.puml` (regenerate with
  `java -jar plantuml.jar -tpng -o "$PWD/img" img/src/*.puml`).
