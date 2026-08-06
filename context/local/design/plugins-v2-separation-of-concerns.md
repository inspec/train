# Train Plugin API v2 — Separation of Concerns

> Scope: this is the **groundwork** for a Train Plugin API v2 — *not* the v2 API itself.
> It inventories every area of concern in the transport/plugin ecosystem and, for each,
> records **who owns it today**, **the problem or tension**, and a **recommended locus of
> responsibility for v2**. It is grounded in the Train source tree and in the two consumer
> studies already written ([InSpec](../integrations/inspec.md),
> [Chef Target Mode](../integrations/chef-infra-client-agentless.md)) and builds directly on
> the [V1 reference](./plugins-v1.md).

## Contents

1. [Purpose & how to read this](#1-purpose--how-to-read-this)
2. [The four actors](#2-the-four-actors)
3. [Master responsibility index](#3-master-responsibility-index)
4. [Group A — Discovery, packaging & loading](#4-group-a--discovery-packaging--loading)
5. [Group B — Configuration & connection setup](#5-group-b--configuration--connection-setup)
6. [Group C — Runtime facilities (the primitives)](#6-group-c--runtime-facilities-the-primitives)
7. [Group D — Cross-cutting operational concerns](#7-group-d--cross-cutting-operational-concerns)
8. [Cross-cutting meta-problems](#8-cross-cutting-meta-problems)
9. [Open questions](#9-open-questions)
10. [Cross-references](#10-cross-references)

---

## 1. Purpose & how to read this

A plugin API is, fundamentally, a **contract about who is responsible for what**. Train V1
grew organically: responsibilities landed wherever was convenient at the time, and several
of them landed in the *wrong* place — transport-specific parsing baked into core, most
transports (ssh, docker, gcp, azure…) bundled into a gem that should carry only `local` and
`mock`, the plugin install/load *lifecycle* pushed entirely onto each client to reinvent,
secret handling owned by nobody, and capability discovery done by clients reaching past the
interface to sniff concrete classes. Before proposing a v2 API we must first name every
concern and decide, deliberately, where it belongs.

Each concern below is written as a short record:

- **What** — the concern in one line.
- **Current locus** — who owns it today, with file/method evidence.
- **Tension** — why the current placement is a problem (or fine).
- **v2** — the recommended locus of responsibility for a redesign.

Concerns marked **[+]** are ones not on the original brainstorm list — the "what have I
missed" additions.

Two diagrams frame the analysis:

![Actors & contract seams](./img/v2-actor-boundaries.png)

*The four actors and the three contract seams between them. The runtime seam (Seam 2) is
deliberately tiny; most of the surface area — and most of the misplaced responsibility —
lives around configuration (Seam 1) and plugin authoring (Seam 3).*

![Recommended locus shifts](./img/v2-locus-shift.png)

*The concerns whose recommended v2 owner differs from today: what moves, and to where. These
ten shifts are the core of the v2 opportunity.*

---

## 2. The four actors

Every responsibility row is assigned to one (occasionally two) of these:

| Actor | Who | Role |
|---|---|---|
| **Core** | Train / train-core gem | Façade (`Train.create`, `load_transport`), global `Plugins.registry`, option DSL, URI parsing, `validate_backend`, `BaseConnection` template methods, result cache, platform-detection engine, error taxonomy, audit-log subsystem. **Should ship only the two bootstrap transports it cannot live without — `local` and `mock` — but today over-bundles ssh/docker/podman/gcp/azure/vmware/cisco_ios.** |
| **Transport** | A transport plugin (ssh, winrm, docker, aws, gcp, `train-rest`, `train-local-rot13`) | Declares options, implements `connection()` + `*_via_connection`, builds `CommandResult`, does auth/sudo, reuses its own socket. In v2 **every** transport except `local`/`mock` is a separate gem. |
| **Client** | InSpec, Chef Target Mode, Test Kitchen | Resolves target/credentials, marshals options into Train, consumes results, rescues `Train::*` exceptions — **and, in InSpec's case, embeds a full plugin host** (install/activate; see below). |
| **Ecosystem** | RubyGems, bundler, **client-embedded plugin host** (InSpec's plugin v2 manager) | Installs and loads gems. The `train-<name>` naming is enforced only by convention. Installation is *not* only the system `gem` command — see the plugin-host note below. |

**The client-embedded plugin host is a first-class actor, not just "the ecosystem."** InSpec
ships a **complete plugin manager independent of the system `gem` command**: it installs
plugin gems into a private prefix `~/.inspec/gems` via `Gem::Installer` / `Gem::RequestSet` /
`Gem::Resolver` (`lib/inspec/plugin/v2/installer.rb`), records them in a `plugins.json`
(`config_file.rb`), and at runtime adds that prefix to `Gem.path` and *activates* the gems and
their dependencies with version constraints (`loader.rb#activate_managed_gems_for_plugin`). It
manages **both** `inspec-*` and `train-*` gems (`list_installed_plugin_gems`), so **installing
and loading a transport is, today, an InSpec responsibility** — not merely RubyGems, and not
Train. Chef Target Mode currently leans on bundler, but is expected to grow its own equivalent.
This duplication (each client re-implementing a transport plugin host) is itself a v2 concern
(§4.2–4.3).

The recurring failure mode is **responsibility bleeding across actors**: Core hardcoding
transport specifics *and shipping transports it shouldn't own*, clients sniffing transport
classes, clients each re-implementing a plugin host, transports each re-implementing what Core
should provide once.

---

## 3. Master responsibility index

Legend: **C** = Core, **T** = Transport, **A** = Client application, **E** = Ecosystem.
An arrow (→) marks a recommended shift.

| # | Concern | Today | v2 (recommended) |
|---|---|---|---|
| **A. Discovery, packaging & loading** ||||
| 1 | Packaging, naming & **core-vs-plugin boundary** | E conv.; C over-bundles | E conv., **C-enforced; core = local+mock only** |
| 2 | Gem installation | E / **A (InSpec plugin host)** | **C-provided host**, used by A |
| 3 | Gem loading / activation | C (in-core path) + **A (InSpec loader)** | **C-provided host**; in-core path = local+mock only |
| 4 | Plugin registration | C (global singleton) | C (**scoped/isolated**) |
| 5 **[+]** | API versioning & capability negotiation | C (`plugin(1)` only) | **C (negotiated)** |
| 6 **[+]** | Discovery & **capability advertisement** | A (class sniffing) | **C + T (manifest)** |
| **B. Configuration & connection setup** ||||
| 7 | Option definition (DSL) | C + T | C + T (unify audit opts) |
| 8 **[+]** | Option namespacing / merge precedence | A + C | A + C (formalize) |
| 9 | URL / target parsing | C (with T-hacks) | **C generic + T hook** |
| 10 | Credential access / credential sets | A | A + **C schema** |
| 11 | Auth & privilege escalation | T | T (unchanged) + C sudo helper |
| 12 **[+]** | Secret / sensitive handling & redaction | *nobody* | **C (option metadata)** |
| 13 **[+]** | Backend validation | C | C (unchanged) |
| 14 **[+]** | Connection lifecycle (open/close/ready) | T | T + **C contract** |
| 15 | Connection reuse / pooling | T + A | **C lifecycle** |
| **C. Runtime facilities** ||||
| 16 | Command execution + result + timeout + stream | C dispatch / T impl | C / T (unchanged) |
| 17 | File read / metadata | C dispatch / T impl | C / T (unchanged) |
| 18 **[+]** | File write / transfer (upload/download) | C + T | C + T (make optional-capability) |
| 19 | HTTP / API request facility | *absent* (A improvises) | **C (uniform primitive)** |
| 20 **[+]** | Interactive session / login / PTY | T | T (unchanged) |
| 21 **[+]** | Platform detection & taxonomy | C engine / T primitives | C + **T strategy** |
| 22 | Result caching (file/command/api) | C | C (unchanged) |
| **D. Cross-cutting operational** ||||
| 23 **[+]** | Error taxonomy & exception contract | C classes / A rescue | **C error codes** |
| 24 **[+]** | Diagnostic logging | C + T | C middleware |
| 25 | Audit logging | C (bolt-on) | **C middleware** |
| 26 **[+]** | Serialization / marshalling | C (partial) | C (generalize) |
| 27 | Test mocking / fixtures | C (Mock) + A | C (first-class) |
| 28 **[+]** | Concurrency / thread-safety | *undefined* | **C contract** |
| 29 **[+]** | Documentation / help generation | T (ad hoc) | C from metadata |

---

## 4. Group A — Discovery, packaging & loading

### 4.1 Packaging, naming & the core-vs-plugin boundary
- **What:** A transport ships as a gem; the gem name encodes the transport name — and,
  separately, **which transports Core itself bundles.**
- **Current locus:** **Ecosystem (naming, by convention) + Core (bundling, badly).**
  `Train.load_transport` maps transport `foo` to `require "train/transports/foo"` **first**
  (in-core) and only then `require "train-foo"` (`lib/train.rb:39-64`). Core therefore ships a
  pile of transports directly in the gem: `local`, `mock`, **plus** `ssh`, `docker`, `podman`,
  `gcp`, `azure`, `vmware`, `cisco_ios`. The `train-` prefix is also load-bearing inside
  InSpec's plugin bridge.
- **Tension:** **No transport belongs in Core except the two it structurally cannot live
  without.** `local` is required because the default target is local and platform detection
  must run *somewhere*; `mock` is required because testing and fixtures are core machinery. Every
  other bundled transport — ssh, docker, podman, and especially the heavyweight cloud API ones
  (`gcp`, `azure`, `vmware`) — drags optional, dependency-heavy code into `train-core` and blurs
  the plugin boundary: the "in-core first" load path means these transports never had to prove
  they work as plugins. `gcp` living in core is the sharpest example — it is an API transport
  with cloud-SDK dependencies sitting in the base gem.
- **v2:** **Core ships only `local` and `mock`.** Everything else is extracted to its own gem
  (`train-ssh`, `train-docker`, `train-gcp`, …) loaded through the *same* plugin path as
  third-party transports — no privileged in-core shortcut. Naming stays an ecosystem convention
  but is **Core-verified** via declared gem metadata (§4.2). This makes the plugin API
  dogfood itself: the built-in transports become plugins like everyone else's.

### 4.2 Gem installation
- **What:** Getting a transport gem onto the system and recorded as available.
- **Current locus:** **Client-embedded plugin host (InSpec), not just the system `gem`
  command.** InSpec's plugin v2 installer (`lib/inspec/plugin/v2/installer.rb`) resolves and
  installs plugin gems into a private prefix (`~/.inspec/gems`) with `Gem::Installer` /
  `Gem::RequestSet` / `Gem::Resolver`, tracks them in `plugins.json` (`config_file.rb`), and
  supports install/update/uninstall/search — a full package manager parallel to (and
  independent of) `gem install`. It manages `train-*` and `inspec-*` gems alike. Chef Target
  Mode relies on bundler today but is expected to grow its own host.
- **Tension:** Installation of *transports* is currently a **client** concern, and **each
  client reinvents the host**. That means transport install/activation semantics (private
  prefix, version pinning, dependency resolution) differ per consumer, and a transport author
  has no single "how do I get installed" story. Train — the thing that actually *defines* what a
  transport is — owns none of this.
- **v2:** Provide a **Core (train-level) plugin host** — a reusable transport install/activate
  facility — that clients delegate to instead of hand-rolling. InSpec's mature manager is the
  template; the goal is that InSpec, Chef, and Kitchen share one transport-plugin lifecycle
  rather than three. The system `gem` command remains a valid fallback path.

### 4.3 Gem loading / activation
- **What:** Loading and activating a transport's code (and its dependencies) at runtime.
- **Current locus:** **Core in-core path + Client loader.** Core's `load_transport` handles the
  `require`; InSpec's `loader.rb` additionally puts `~/.inspec/gems` on `Gem.path` and
  *activates* managed gems with version constraints
  (`activate_managed_gems_for_plugin`). So activation of a plugin transport is, again, a
  client responsibility.
- **Tension:** The in-core `require "train/transports/<name>"` shortcut (§4.1) means bundled
  transports load by a different mechanism than plugin transports — two code paths for one
  concept. And activation-with-constraints lives in the client, not Train.
- **v2:** Collapse to **one** loading path via the Core plugin host: `local`/`mock` load
  in-core, everything else activates as a managed gem through the same facility, with the
  version/capability handshake (§4.5) applied uniformly.

### 4.4 Plugin registration
- **What:** Making a loaded transport findable by name.
- **Current locus:** **Core**, via a **global mutable singleton**: `self.name(name)` writes
  `Train::Plugins.registry[name] = self` (`plugins/transport.rb`), and `registry` is a
  process-wide `@registry ||= {}` (`plugins.rb`).
- **Tension:** Global mutable state: no isolation between clients embedding Train, no
  namespacing, last-registration-wins, and no way to run two API versions side by side.
- **v2:** **Core, scoped/isolated** registry (an injectable registry instance), versioned so
  a v1 and v2 transport can coexist during migration.

### 4.5 API versioning & capability negotiation **[+]**
- **What:** How a plugin declares which API it targets, and how Core decides what to offer it.
- **Current locus:** **Core**, but frozen: `Train.plugin(version=1)` raises for anything but
  `1` (`plugins.rb`). There is exactly one version and no negotiation.
- **Tension:** This is *the* v2 seam. Today a plugin author gets an all-or-nothing base class;
  there is no way to opt into new facilities, advertise what it supports, or migrate
  incrementally.
- **v2:** **Core-owned negotiated version.** `Train.plugin(2)` returns a base whose available
  mixins are gated by a declared **capability set** (§4.6). Version + capabilities together
  replace the current monolith.

### 4.6 Discovery & capability advertisement **[+]**
- **What:** Enumerating available transports and knowing what each can *do* (run commands?
  files? http? platform detect? upload?).
- **Current locus:** **Client, by class-name sniffing** — even though the client-embedded
  plugin host *already enumerates installed plugins* (`list_installed_plugin_gems` filters
  gems by `train-`/`inspec-` prefix; `plugins.json` records them). Enumeration exists; a
  *capability* API does not, so consumers still reach past the interface: InSpec's `http`
  resource branches on `is_a?(Train::Transports::Local::Connection)`; the resource base
  bypasses platform support when `backend.class == Train::Transports::Mock::Connection`; Chef
  Target Mode makes similar class checks. (See [InSpec study §9](../integrations/inspec.md) and
  [Chef study](../integrations/chef-infra-client-agentless.md).)
- **Tension:** Class-name sniffing is the single most pervasive smell in the ecosystem. It
  couples clients to concrete transport classes, breaks encapsulation, and makes new
  transports invisible unless clients are patched. The plugin host can tell you a transport is
  *installed*, but nothing tells you what it can *do*.
- **v2:** **Core + Transport capability manifest.** Transports *declare* capabilities
  (`:command`, `:file_read`, `:file_write`, `:http`, `:platform_detect`, `:interactive`);
  Core exposes `connection.supports?(:http)` and clients query capabilities instead of
  sniffing classes.

---

## 5. Group B — Configuration & connection setup

### 5.1 Option definition (the option DSL)
- **What:** Declaring a transport's configuration options with defaults/validation.
- **Current locus:** **Core provides the DSL, Transport declares.** `Train::Options` gives
  `option name, default:/required:/coerce:` and `include_options` (`lib/train/options.rb`);
  transports call it at class level.
- **Tension:** Adequate, but the **audit-log options are bolted on beside the DSL**
  (`default_audit_log_options`, `validate_audit_log_options`) with comments admitting they
  are kept separate "so it will not break existing functionality." Cross-cutting options are
  not composable through the same mechanism.
- **v2:** Keep the DSL; make cross-cutting option groups (audit, logging, timeouts) first-class
  **composable modules** rather than special-cased methods.

### 5.2 Option namespacing / prefixing / merge precedence **[+]**
- **What:** Turning CLI flags / env / config files into a validated per-transport option hash,
  with a defined precedence.
- **Current locus:** **Client + Core.** Clients filter/unprefix using `Train.options(name)`
  as the authoritative key list (InSpec's `_utc_merge_transport_options`; Chef's Target Mode
  does the same). `Train.options(name)` is therefore a **de-facto public contract**.
- **Tension:** The precedence (CLI > env > file > default) lives entirely in each client and
  is re-implemented per consumer; Core only supplies the key list.
- **v2:** Keep marshalling in the client, but have Core **formally publish** the option schema
  (types, precedence hints, sensitivity) so clients stop re-deriving it.

### 5.3 URL / target parsing
- **What:** Turning `scheme://user:pass@host:port/path?query` into a credentials hash and a
  transport name.
- **Current locus:** **Core**, `Train.unpack_target_from_uri` / `parse_uri` (`lib/train.rb`).
- **Tension:** Core contains **transport-specific hacks**: `www_form_encoded_password` for one
  case, and literal `# TODO: move logic into winrm plugin` / `# move logic into SSH plugin`
  comments where core special-cases empty paths and key handling. The generic parser knows too
  much about specific transports.
- **v2:** **Core stays generic**; transports provide an optional **URI-parsing hook** to
  interpret their own scheme (as the code comments already wish). New transports are
  encouraged toward `transport://credset` (RFC-099) to avoid bespoke field mapping.

### 5.4 Credential access & credential sets
- **What:** Sourcing secrets, including layered credential files.
- **Current locus:** **Client.** InSpec implements RFC-099
  `credentials/<transport>/<credset>` resolution in `config.rb`; Chef resolves its own.
- **Tension:** Every client re-implements credential-set precedence; Core has no notion of it.
- **v2:** Keep sourcing in the client, but define a **Core credential schema** (which options
  are credentials, which are sensitive) so redaction (§5.6) and validation are consistent.

### 5.5 Auth & privilege escalation
- **What:** Authenticating (keys, passwords, tokens) and elevating (sudo, runas).
- **Current locus:** **Transport.** SSH owns keys + `sudo`/`sudo_password`/`sudo_options` and
  `with_sudo_pty`; WinRM owns its auth; cloud transports own token/credential chains.
- **Tension:** Reasonable that auth is transport-specific, but **sudo/PTY logic is duplicated**
  across shell transports with no shared helper, and `with_sudo_pty` is a no-op in the base.
- **v2:** Auth stays with the Transport; extract a **Core shell-escalation helper** shared by
  shell-family transports.

### 5.6 Secret / sensitive option handling & redaction **[+]**
- **What:** Marking options as secret so they are never logged/serialized in cleartext.
- **Current locus:** **Nobody.** There is no `sensitive` flag anywhere in Train (`grep
  sensitive|redact lib/train` → nothing). Passwords/tokens flow through option hashes and can
  surface in logs, audit records, and `inspect` output.
- **Tension:** A real security gap. The audit-log subsystem writes option-derived fields; the
  diagnostic logger debug-prints; neither redacts.
- **v2:** **Core option metadata** (`option :password, sensitive: true`) enforced centrally in
  logging, audit, and `inspect`.

### 5.7 Backend validation **[+]**
- **What:** Rejecting a misconfigured target before connecting.
- **Current locus:** **Core.** `Train.validate_backend` picks the transport; `validate_options`
  enforces `required:` options (`options.rb`).
- **Tension:** Minimal — validation is shallow (required-key presence only; no type or
  cross-field checks) and audit-log options are validated by a *separate* method.
- **v2:** Keep in Core; deepen to schema-based validation (types, mutually-exclusive fields)
  and fold audit-option validation into the same path.

### 5.8 Connection lifecycle **[+]**
- **What:** Open → ready → use → close (and reconnect) semantics.
- **Current locus:** **Transport.** `connection()` builds it; `close`, `wait_until_ready`,
  `login_command` are base no-ops/`NotImplementedError` each transport fills in
  (`base_connection.rb`).
- **Tension:** No contract for *when* Core or clients should call `close`; lifecycle is
  implicit and leaks (InSpec keeps connections alive by caching the whole backend).
- **v2:** Transports still implement open/close, but **Core owns the lifecycle contract** —
  defined states, guaranteed teardown, reconnect policy.

### 5.9 Connection reuse / pooling
- **What:** Avoiding re-dialing the same target.
- **Current locus:** **Transport + Client.** Each transport reinvents reuse (SSH keeps
  `@connection` + `reusable_connection?` comparing `@connection_options`,
  `ssh.rb:83,125-128,285-319`); clients additionally cache the whole backend object.
- **Tension:** Reuse logic is duplicated per transport and again per client; there is no shared
  pool, no keyed cache in Core (the Core cache is for *results*, not connections — §6.7).
- **v2:** **Core connection lifecycle/pool** keyed by connection options; transports implement
  only open/close.

---

## 6. Group C — Runtime facilities (the primitives)

### 6.1 Command execution
- **What:** Run a command, get stdout/stderr/exit status, optionally streamed, with a timeout.
- **Current locus:** **Core dispatch, Transport implementation.** `BaseConnection#run_command`
  handles caching, the audit hook, and an **arity shim** (1- vs 2-arg
  `run_command_via_connection`) before delegating; transports implement the private method and
  build `CommandResult` (`extras.rb:8` = `Struct.new(:stdout,:stderr,:exit_status)`). Timeouts
  surface as `Train::CommandTimeoutReached`. A `data_handler` block enables streaming.
- **Tension:** The arity shim is a compatibility hack betraying that the signature is not a firm
  contract. `CommandResult` has no exit-signal / duration / truncation fields.
- **v2:** Keep the dispatch/implement split; freeze a **richer result contract** and a single
  command signature (options hash always present).

### 6.2 File read / metadata
- **What:** `connection.file(path)` → uniform metadata (content, mode, owner, mtime, type…).
- **Current locus:** **Core dispatch, Transport implementation.** `BaseConnection#file` caches
  and delegates to `file_via_connection`; per-OS file classes live under `lib/train/file/`.
- **Tension:** The `Train::File` API is large and implicitly contractual — arguably the second
  hidden contract after platform detection (§6.6). Not every transport can honor all of it.
- **v2:** Keep the split; make the file API a **capability-gated** interface (a transport
  declares which metadata it supports) rather than an all-or-nothing base class.

### 6.3 File write / transfer **[+]**
- **What:** Writing file content and moving files (`content=`, `upload`, `download`).
- **Current locus:** **Core + Transport.** `BaseConnection` implements `upload`/`download` in
  terms of `file(...).content` / `content=`; transports back the actual write.
- **Tension:** Train is commonly assumed read-only, but it is not — yet write support is
  uneven and undiscoverable (no capability flag), so clients cannot know if `upload` works.
- **v2:** Keep Core orchestration; gate behind a declared `:file_write` capability (§4.6).

### 6.4 HTTP / API request facility
- **What:** A uniform way to make an HTTP/API request through the transport.
- **Current locus:** **Absent — clients improvise.** Train has no HTTP primitive. InSpec's
  `http` resource branches on local-vs-remote and uses Ruby `Net::HTTP` locally or a remote
  worker; Chef Target Mode faked HTTP via `curl`/`wget`. API transports (aws/azure/gcp) expose
  *client objects* (`gcp_compute_client`, etc.) instead of a request primitive.
- **Tension:** The most impactful missing primitive: every consumer reinvents remote HTTP, and
  API transports each expose bespoke client accessors with no common shape.
- **v2:** **Core-defined request primitive** (`connection.http(...)` or similar), capability
  gated, so consumers stop improvising and API transports share a surface.

### 6.5 Interactive session / login / PTY **[+]**
- **What:** Opening an interactive shell or feeding stdin/PTY.
- **Current locus:** **Transport.** `login_command` (base raises `NotImplementedError`),
  `with_sudo_pty`.
- **Tension:** Minor; genuinely transport-specific.
- **v2:** Stays with the Transport, capability gated (`:interactive`).

### 6.6 Platform detection & OS/family taxonomy **[+]**
- **What:** Deciding *what the target is* — OS, release, family hierarchy, uuid.
- **Current locus:** **Core engine driven through Transport primitives.** `Detect.scan(backend)`
  (`platforms/detect.rb:6`) runs a decision tree using the transport's `run_command`/`file`;
  the taxonomy lives in `specifications/os.rb` and `specifications/api.rb`; API transports skip
  detection via `force_platform!`. `Platforms.export` publishes the taxonomy (InSpec embeds it
  in its JSON schema).
- **Tension:** This is arguably the **largest and least-acknowledged contract** in Train. The
  detection engine *assumes* shell/file primitives exist, which is why API transports must
  bypass it entirely. Adding a platform means editing core specifications — plugins cannot
  contribute taxonomy.
- **v2:** Core keeps the engine + taxonomy, but transports declare a **detection strategy**
  (`:shell` | `:api` | `:force`) and can **contribute platform definitions**, so detection is
  not hardwired to shell transports.

### 6.7 Result caching
- **What:** Memoizing file/command/api results within a connection.
- **Current locus:** **Core.** `BaseConnection` has a three-way cache: `:file` **on by
  default**, `:command` and `:api_call` **off** (`base_connection.rb`), with
  `enable_cache`/`disable_cache` and `UnknownCacheType`.
- **Tension:** Cache defaults are surprising (files cached, commands not) and are per-connection
  policy that clients must know to override. It is separate from *connection* reuse (§5.9),
  which is easy to confuse.
- **v2:** Keep in Core; make defaults explicit and per-capability; clearly separate *result*
  cache from *connection* pool in naming.

---

## 7. Group D — Cross-cutting operational concerns

### 7.1 Error taxonomy & exception contract **[+]**
- **What:** The set of errors Core/transports raise and how clients handle them.
- **Current locus:** **Core defines classes, Client rescues them.** `lib/train/errors.rb`:
  `Error` → `UserError`/`ClientError`/`TransportError` + `PlatformDetectionFailed`,
  `CommandTimeoutReached`, `PluginLoadError`, etc. Clients `rescue Train::ClientError`,
  `Train::TransportError` **by class name** (InSpec `backend.rb`, Chef Target Mode).
- **Tension:** Rescue-by-class couples clients to Core's class hierarchy; transports sometimes
  raise generic `RuntimeError`; the `reason` symbol on `Error` is under-used. There is no
  stable, documented error *code* contract.
- **v2:** **Core error contract** with declared, documented **error codes/categories**
  (machine-readable `reason`), so clients switch on a code, not a class.

### 7.2 Diagnostic logging **[+]**
- **What:** Developer/debug logging of connection activity.
- **Current locus:** **Core + Transport.** A `:logger` option threads a `Logger` into
  `Transport`/`BaseConnection`; transports `logger.debug(...)`.
- **Tension:** Distinct from audit logging (§7.3) but not clearly separated; no redaction
  (§5.6); default logger config is ad hoc (`Logger.new($stdout, level: :fatal)`).
- **v2:** Fold into a **Core cross-cutting middleware** layer with consistent redaction.

### 7.3 Audit logging
- **What:** Structured record of every command/file/upload for compliance.
- **Current locus:** **Core (bolt-on).** `Train::AuditLog` (JSON logger) is instantiated in
  `BaseConnection#initialize` from `enable_audit_log`/`audit_log_*` options, and hooks fire
  inside `run_command`, `file`, and `upload`.
- **Tension:** Grafted on beside the option DSL (its own option set + own validation method,
  per the code's own comments), duplicates option data into `@audit_log_data`, and logs
  unredacted fields.
- **v2:** Promote to a proper **Core middleware/interceptor** around the primitive dispatch,
  sharing redaction and option handling with diagnostic logging (§7.2).

### 7.4 Serialization / marshalling **[+]**
- **What:** Persisting/transferring connection state (e.g. file cache to a remote worker or a
  mock fixture).
- **Current locus:** **Core (partial).** `BaseConnection#to_json` / `load_json` serialize the
  *file* cache into/out of the Mock transport's file objects.
- **Tension:** Only the file cache is covered; command results and platform aren't; it is
  entangled with the Mock transport specifically.
- **v2:** Generalize into a **Core-owned serialization contract** for results/fixtures,
  independent of Mock.

### 7.5 Test mocking / fixtures
- **What:** Emulating targets for tests without real connectivity.
- **Current locus:** **Core (Mock transport) + Client.** `Train::Transports::Mock` and
  `plugin_test_helper` live in core; InSpec builds the `mock_loader` (~40 emulated OSes) and,
  critically, the resource base **special-cases the Mock class** to bypass platform-support
  gating.
- **Tension:** Mock is a test double wired into *production* control flow via class-name checks
  — the capability-discovery smell (§4.6) in its purest form.
- **v2:** Keep Mock in Core as a **first-class transport** advertising capabilities, so clients
  test against capabilities rather than `== Mock::Connection`.

### 7.6 Concurrency / thread-safety **[+]**
- **What:** Whether a connection may be shared across threads / used concurrently.
- **Current locus:** **Undefined.** No documented thread-safety guarantee; SSH keeps a single
  mutable `@connection`; the global registry is shared.
- **Tension:** Consumers that parallelize (runners, servers) have no contract to rely on.
- **v2:** **Core-defined thread-safety contract** per connection (e.g. "not thread-safe; one
  connection per thread") and a thread-safe registry.

### 7.7 Documentation / help generation **[+]**
- **What:** Human-facing docs for a transport's options and capabilities.
- **Current locus:** **Transport (ad hoc).** Option help is prose in READMEs; nothing is
  generated from the option DSL.
- **Tension:** Options carry no `desc:`/help metadata, so CLIs cannot auto-document transports.
- **v2:** Add help/description metadata to the option DSL and **generate** transport docs from
  it in Core.

---

## 8. Cross-cutting meta-problems

Eight themes recur across the table above; a v2 design should treat these as first-order
goals, not incidental fixes:

1. **Convention over contract.** The `train-` gem prefix and the `require` path are
   load-bearing but unenforced and undiscoverable until failure (§4.1, §4.3). v2 should make
   plugin identity *declared*, not filename-derived.

2. **Class-name sniffing instead of capability negotiation.** The single most pervasive smell:
   `is_a?(Local::Connection)`, `== Mock::Connection`, `local_transport?` across InSpec and
   Chef (§4.6, §6.4, §7.5). v2 must provide a **capability manifest** so no consumer reaches
   past the interface.

3. **Global mutable singleton state.** One process-wide registry, last-writer-wins, no
   isolation or versioning (§4.4). v2 needs scoped, versioned registration to allow migration.

4. **Bolt-on cross-cutting concerns.** Audit logging (and to a lesser extent diagnostic
   logging, redaction, timeouts) are grafted beside the core mechanisms rather than composed
   through a middleware layer (§5.1, §7.2, §7.3). v2 should have one interceptor pipeline.

5. **Leaky core.** Transport-specific knowledge is hardcoded into generic core code —
   `www_form_encoded_password`, the `# move logic into ssh/winrm plugin` TODOs, the
   detection engine assuming shell primitives (§5.3, §6.6). v2 should push these to
   transport-provided hooks.

6. **Rescue/read coupling to concrete types.** Clients depend on Core exception *classes*
   (§7.1) and concrete transport *classes* (theme 2) rather than declared codes/capabilities.
   v2 should expose stable machine-readable contracts (error codes, capability flags) so
   consumers never bind to Ruby class identity.

7. **Core over-bundles transports.** `train-core` ships ssh, docker, podman, gcp, azure,
   vmware, and cisco_ios directly, with a privileged "in-core first" load path that ordinary
   plugins don't get (§4.1). Only `local` and `mock` are structurally required in Core. v2
   should extract every other transport to its own gem loaded through the *same* path as
   third-party plugins — so the built-in transports dogfood the plugin API.

8. **Every client reinvents the plugin host.** InSpec already has a complete, mature transport
   install/activate manager (private `~/.inspec/gems`, `Gem::Resolver`, `plugins.json`,
   version-constrained activation) that is entirely separate from the system `gem` command
   (§4.2, §4.3); Chef is expected to grow its own. Train — which *defines* what a transport is
   — owns none of this, so the lifecycle is duplicated and divergent per consumer. v2 should
   offer a shared, train-level plugin host that clients delegate to.

The through-line: **V1 leaks implementation identity across every seam** — filenames, class
names, exception classes, hardcoded transport specifics, and privileged in-core transports —
while pushing the plugin *lifecycle* out to each client to reinvent. A v2 API is fundamentally
about replacing leaked identity with **declared contracts** (capabilities, error codes, option
schemas, lifecycle states) and pulling the **plugin host** into a shared, reusable facility so
that Core owns only `local`+`mock` and everyone — built-in or third-party — is a plugin on
equal terms.

---

## 9. Open questions

These need decisions before (or during) the v2 API design proper:

1. **Migration model.** Can v1 and v2 transports coexist in one process (dual registry), or is
   v2 a hard break? This gates the registry/versioning design (§4.4, §4.5).
2. **Capability granularity.** How fine-grained should capabilities be — coarse
   (`:command`/`:file`/`:http`) or fine (`:file_write`, `:file_chmod`, `:command_stream`)?
3. **Is the file API too big?** Should the rich `Train::File` metadata surface be trimmed or
   split into capability tiers (§6.2)?
4. **HTTP primitive shape.** A generic request/response object, or a thin adapter over
   `Faraday`/`Net::HTTP`, and how do API-client transports (aws/gcp) map onto it (§6.4)?
5. **Platform taxonomy ownership.** Can plugins contribute platform definitions, or does the
   taxonomy stay a curated core artifact that clients (InSpec schema) depend on (§6.6)?
6. **Where does credential-set resolution belong** long term — permanently in each client, or
   a shared Core/`train`-level resolver (§5.4)?
7. **Thread-safety guarantee.** What contract do we commit to, given parallel runners
   (§7.6)?
8. **Backward compatibility of `Train.options`.** It is a de-facto public contract for InSpec
   *and* Chef; any change to option publishing must preserve it (§5.2).
9. **Plugin host ownership & reuse.** Should Train ship a reusable transport plugin host
   (install/activate) that InSpec and Chef delegate to, or does each client keep its own? If
   shared, does it subsume InSpec's mature `~/.inspec/gems` manager or wrap it (§4.2, §4.3)?
10. **Extracting the built-in transports.** What is the migration path to move ssh/docker/
   gcp/azure/vmware/cisco_ios out of `train-core` into gems without breaking consumers who
   assume they are always present (§4.1)? Do `local`/`mock` stay the only in-core transports?

---

## 10. Cross-references

- [Train Plugin API — Version 1 (V1) Reference](./plugins-v1.md) — the current contract this
  redesign starts from; especially [§7 Data contracts](./plugins-v1.md#7-data-contracts),
  [§8 Options, target URIs & credentials](./plugins-v1.md#8-options-target-uris--credentials),
  and [§13 Limitations & observations](./plugins-v1.md#13-limitations--observations-springboard-for-v2).
- [InSpec's usage of Train](../integrations/inspec.md) — the class-name-sniffing,
  `Train.options` contract, and Mock-as-core evidence behind §4.6, §5.2, §7.5.
- [Chef Infra Client "Target Mode" (Agentless)](../integrations/chef-infra-client-agentless.md)
  — the parallel consumer showing the missing HTTP primitive (§6.4) and the same option-
  filtering contract (§5.2).
