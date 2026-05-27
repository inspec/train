## Plan

Exercise: ex13

### Goal / Outcome
Reduce behavior-change risk by introducing a reversible feature flag around command-completion audit telemetry, documenting the flag lifecycle, and validating both ON and OFF modes locally.

### Scope
- Keep current behavior by default.
- Add a kill-switch style flag for `cmd_complete` audit events.
- Add explicit ON/OFF unit coverage.
- Document lifecycle and removal guidance.

### Steps
1. Introduce a feature flag in connection audit telemetry path.
2. Add unit tests for both states:
   - default/ON emits `cmd_complete`
   - OFF disables `cmd_complete` while preserving `cmd` start event
3. Update audit-log docs with lifecycle details:
   - creation
   - default state
   - enable/disable instructions
   - removal trigger
4. Run targeted local validation in both modes and capture output.

### Files to change
- `lib/train/plugins/base_connection.rb`
  - Add env-flag check for command-completion event emission.
- `test/unit/plugins/connection_test.rb`
  - Add ON/OFF validation tests and env isolation.
- `docs/audit_log.md`
  - Add feature-flag lifecycle section.
- `.copilot-track/walk/ex13/notes.md`
  - Capture local ON/OFF validation commands and outputs.

### Test strategy
- Run targeted unit tests locally in two modes:
  - default mode (flag unset)
  - OFF mode (`TRAIN_ENABLE_CMD_COMPLETE_AUDIT=0`)
- Command:
  - `bundle exec ruby -Itest test/unit/plugins/connection_test.rb`
  - `TRAIN_ENABLE_CMD_COMPLETE_AUDIT=0 bundle exec ruby -Itest test/unit/plugins/connection_test.rb`

### Evidence to capture (coverage/contract)
- Test output from both runs in ex13 notes.
- Contract assertion:
  - ON/default: `cmd_complete` event present.
  - OFF: `cmd_complete` event absent; command-start `cmd` event still present.

### Rollback
- Revert commit touching:
  - `lib/train/plugins/base_connection.rb`
  - `test/unit/plugins/connection_test.rb`
  - `docs/audit_log.md`
  - `.copilot-track/walk/ex13/notes.md`

### Out of scope
- No CI matrix expansion in this step (local dual-mode validation only).
- No changes to transport-specific API/file event instrumentation.
