## Plan

Exercise: ex9

### Goal / Outcome
Improve visibility into system behavior by adding one low-risk instrumentation hook and documenting where to view it.

### Instrumentation options considered
1. Command execution latency and exit status (chosen)
- Pros: high-value operational signal, applies across transports, uses existing audit logging path.
- Risk: low; additive audit-log payload only.

2. File access counters
- Pros: broad usage.
- Cons: less actionable than command latency.

3. Transport connection timing
- Pros: useful for connectivity diagnostics.
- Cons: distributed across transport plugins; larger change surface.

### Chosen instrumentation point
- `Train::Plugins::Transport::BaseConnection#run_command`
- Add an audit-log completion event after command execution including:
  - command
  - duration_ms
  - exit_status (if available)
  - cache_hit flag for command cache path
  - user / hostname metadata when available

### Files to change
- `lib/train/plugins/base_connection.rb`
  - Add command completion telemetry event and timing measurement.
- `test/unit/plugins/connection_test.rb`
  - Add/extend test coverage to assert new audit log event payload.
- `docs/audit_log.md`
  - Document the new command completion event and where to view it.
- `.copilot-track/walk/ex9/notes.md` (new)
  - Record verification output and rollback guidance.

### Test strategy
- Targeted unit tests:
  - `bundle exec ruby -Ilib:test test/unit/plugins/connection_test.rb`
- Optional broader check:
  - `bundle exec rake test`

### Evidence to capture (coverage/contract)
- Unit test output showing assertions for new telemetry event.
- Local sample of audit log JSON including new completion event keys.
- Coverage/contract note:
  - behavior of command execution is unchanged; only additive observability metadata.

### Rollback
- Revert commit touching:
  - `lib/train/plugins/base_connection.rb`
  - `test/unit/plugins/connection_test.rb`
  - `docs/audit_log.md`
  - `.copilot-track/walk/ex9/*`

### Troubleshooting
- If no audit log is configured (`enable_audit_log: false`), no telemetry file output is expected.
- If duration is unexpectedly missing, validate command invocation path and that completion logging executes on both arities.
