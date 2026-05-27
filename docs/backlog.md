# Train Backlog Epic

This document captures future work discovered while completing the Walk exercise chain. It is a repository-local fallback for tracker items and is intended to be converted into issues later if tracker access is available.

## Epic Scope

Improve Train's reliability, observability, and CI signal quality by addressing follow-up work identified during exercises ex6-ex11.

## Non-Goals

- No broad transport rewrites in one change.
- No multi-feature PRs that mix unrelated runtime and process work.
- No item should exceed one focused PR.

## Backlog Items

### 1. Fix key file classification bug in target config

Why this exists:
- ex6 benchmarking exposed a bug in `Train.target_config` key handling when `keys` are present.
- `group_keys_and_keyfiles` calls `File.file?` from inside the `Train` namespace, which risks resolving to `Train::File` instead of Ruby's top-level `::File`.

Code paths:
- `lib/train.rb`
- `test/unit/train_test.rb`

Acceptance criteria:
- `Train.target_config` correctly classifies key file paths and inline keys when `keys` is provided.
- Regression tests cover string keys, symbol keys, real file paths, and inline key content.
- No behavior regression for existing `target_config` URI parsing behavior.

Dependencies:
- None.

Suggested PR size:
- Runtime fix plus targeted unit tests.

### 2. Expand audit logging to API and file lifecycle parity

Why this exists:
- `docs/audit_log.md` documents current audit-log limitations.
- ex9 added `cmd_complete`, but API operations and some file lifecycle events still lack consistent audit visibility.

Code paths:
- `lib/train/plugins/base_connection.rb`
- `docs/audit_log.md`
- `lib/train/transports/azure.rb`
- `lib/train/transports/gcp.rb`
- `lib/train/file/remote/`

Acceptance criteria:
- Add an explicit event model for API calls and download/file-completion operations.
- Update documentation with new event types and sample payloads.
- Add focused tests for each newly instrumented event family.

Dependencies:
- Builds on ex9 command-completion event shape for consistency.

Suggested PR size:
- One event family at a time if needed (API first, then file lifecycle).

### 3. Add connection lifecycle telemetry for open/close/failure paths

Why this exists:
- ex9 improved command-level visibility, but connection setup/teardown and failures still require transport-specific debugging.

Code paths:
- `lib/train/plugins/base_connection.rb`
- `lib/train/transports/ssh_connection.rb`
- `lib/train/transports/docker.rb`
- `lib/train/transports/podman.rb`
- `docs/audit_log.md`

Acceptance criteria:
- Emit structured events for connection open, close, and failure paths where practical.
- Include timing and error classification where available.
- Add transport-scoped tests for at least one remote and one container transport.

Dependencies:
- Depends on backlog item 2 if a shared audit event schema is introduced there.

Suggested PR size:
- Start with one transport family, then expand incrementally.

### 4. Consolidate secret scanning into the main PR CI flow

Why this exists:
- ex8 added a focused `secret-scan.yml`, but secret scanning is also referenced in the shared main PR stub inputs.
- Current repo-level setup risks duplicated or divergent CI behavior over time.

Code paths:
- `.github/workflows/ci-main-pull-request-stub.yml`
- `.github/workflows/secret-scan.yml`
- `.trufflehogignore`
- `SECURITY.md`

Acceptance criteria:
- Define one clear source of truth for secret scanning in PR CI.
- Preserve documented false-positive handling with narrow ignore rules.
- Document whether the repo uses dedicated workflow, shared stub, or both intentionally.

Dependencies:
- None.

Suggested PR size:
- CI/workflow cleanup plus docs only.

### 5. Promote advisory coverage evidence into the main PR experience

Why this exists:
- ex10 added a separate advisory coverage summary workflow, but coverage evidence is still separate from the shared main PR CI flow.
- Reviewers would benefit from a single place to find advisory validation output.

Code paths:
- `.github/workflows/coverage-summary.yml`
- `.github/workflows/ci-main-pull-request-stub.yml`
- `contrib/write_coverage_summary.rb`
- `README.md`

Acceptance criteria:
- Surface advisory coverage evidence in the primary PR CI path or an attached PR comment.
- Keep the signal explicitly non-blocking.
- Allow threshold changes without code duplication.

Dependencies:
- May depend on decisions made in backlog item 4 if CI consolidation changes the workflow layout.

Suggested PR size:
- CI integration plus summary script/docs updates.

## Dependency Summary

- Item 1 has no dependencies.
- Item 2 should land before item 3 if shared audit event semantics are introduced.
- Item 4 is independent but may influence how item 5 is implemented.
- Item 5 should account for CI layout decisions from item 4.

## Recommended Order

1. Fix key file classification bug in target config.
2. Expand audit logging to API and file lifecycle parity.
3. Add connection lifecycle telemetry.
4. Consolidate secret scanning into the main PR CI flow.
5. Promote advisory coverage evidence into the main PR experience.
