## Summary
- Added a reversible feature flag for command-completion telemetry: `TRAIN_ENABLE_CMD_COMPLETE_AUDIT`.
- Kept default behavior unchanged (enabled when unset).
- Added tests to validate both ON/default and OFF modes.
- Documented flag lifecycle, enable/disable instructions, and removal criteria.

## What Changed
- `lib/train/plugins/base_connection.rb`
  - Gate `cmd_complete` emission behind `command_completion_audit_enabled?`.
  - Parse disable values: `0`, `false`, `no`, `off`.
- `test/unit/plugins/connection_test.rb`
  - Added env helper for isolated flag tests.
  - Added OFF-mode test and process-level mode test.
  - Kept cache-hit telemetry assertions with explicit ON mode.
- `docs/audit_log.md`
  - Added feature flag lifecycle section with shell examples.

## Validation
Lint:

```text
Inspecting 2 files
..

2 files inspected, no offenses detected
CHEFSTYLE_EXIT:0
```

Default mode (unset flag):

```text
30 runs, 66 assertions, 0 failures, 0 errors, 0 skips
```

OFF mode (`TRAIN_ENABLE_CMD_COMPLETE_AUDIT=0`):

```text
30 runs, 66 assertions, 0 failures, 0 errors, 0 skips
```

## Acceptance Mapping
- Flag lifecycle documented: yes
- ON/OFF validated: yes
- Tests updated: yes

## Risk & Rollback
- Risk: low, behavior-preserving by default with reversible flag.
- Rollback:
  - Revert commit touching `base_connection.rb`, `connection_test.rb`, and `audit_log.md`.

## Review Focus
- Confirm default behavior is unchanged when flag is unset.
- Confirm OFF mode suppresses only `cmd_complete` event.
- Confirm docs accurately describe lifecycle and decommission criteria.

## Track
- Level: Walk
- Exercise: ex13
