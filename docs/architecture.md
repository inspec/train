# Architecture Overview

This document maps the main Train concepts to the real files in this repository and shows the most important dependency and data flows.

The Mermaid source for the diagram lives in [docs/architecture.mmd](architecture.mmd) so CI can render the exact same graph.

## Concept to Path Map

- Entry point and orchestration: [lib/train.rb](../lib/train.rb)
- Plugin registry and plugin base: [lib/train/plugins.rb](../lib/train/plugins.rb) and [lib/train/plugins/transport.rb](../lib/train/plugins/transport.rb)
- Shared connection behavior: [lib/train/plugins/base_connection.rb](../lib/train/plugins/base_connection.rb)
- Option handling: [lib/train/options.rb](../lib/train/options.rb)
- Platform model and detection: [lib/train/platforms.rb](../lib/train/platforms.rb), [lib/train/platforms/detect.rb](../lib/train/platforms/detect.rb), [lib/train/platforms/platform.rb](../lib/train/platforms/platform.rb), [lib/train/platforms/family.rb](../lib/train/platforms/family.rb), [lib/train/platforms/common.rb](../lib/train/platforms/common.rb)
- File abstraction: [lib/train/file.rb](../lib/train/file.rb), [lib/train/file/local.rb](../lib/train/file/local.rb), [lib/train/file/remote.rb](../lib/train/file/remote.rb)
- Core transports: [lib/train/transports/local.rb](../lib/train/transports/local.rb), [lib/train/transports/mock.rb](../lib/train/transports/mock.rb), [lib/train/transports/ssh.rb](../lib/train/transports/ssh.rb), [lib/train/transports/docker.rb](../lib/train/transports/docker.rb), [lib/train/transports/podman.rb](../lib/train/transports/podman.rb)
- Transport helpers and support code: [lib/train/transports/ssh_connection.rb](../lib/train/transports/ssh_connection.rb), [lib/train/transports/cisco_ios_connection.rb](../lib/train/transports/cisco_ios_connection.rb), [lib/train/transports/clients/](../lib/train/transports/clients/), [lib/train/transports/helpers/](../lib/train/transports/helpers/)

## Mermaid Diagram

```mermaid
See [architecture.mmd](architecture.mmd) for the canonical Mermaid source used by CI.
```

## Dependency Flow

1. `lib/train.rb` loads the plugin registry and resolves a transport by name.
2. `lib/train/plugins.rb` stores the transport class selected by the registry.
3. A transport such as [lib/train/transports/ssh.rb](../lib/train/transports/ssh.rb) inherits from [lib/train/plugins/transport.rb](../lib/train/plugins/transport.rb) and uses [lib/train/plugins/base_connection.rb](../lib/train/plugins/base_connection.rb) for the shared connection contract.

## Data Flow

1. A caller passes a target hash or URI into `Train.create` or into the target parsing helpers in [lib/train.rb](../lib/train.rb).
2. `target_config`, `unpack_target_from_uri`, and `validate_backend` normalize the input into transport options.
3. The chosen transport receives those options, establishes a connection, and routes command/file requests through its connection implementation.
4. The connection returns command output or file content through [lib/train/file.rb](../lib/train/file.rb) and the transport-specific file classes under [lib/train/file/local.rb](../lib/train/file/local.rb) and [lib/train/file/remote.rb](../lib/train/file/remote.rb).

## Notes

- The architecture should be kept aligned with the actual files in `lib/` rather than the broader support matrix described in the README.
- This repository currently contains the transports listed above; the doc intentionally avoids mapping concepts to files that are not present in the tree.