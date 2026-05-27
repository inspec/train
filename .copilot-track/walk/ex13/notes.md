## ex13 notes

Date: 2026-05-27

### Goal
Reduce risk for behavior changes by introducing a reversible feature flag for command-completion audit telemetry, documenting lifecycle, and validating both ON and OFF modes.

### Feature flag
- Name: `TRAIN_ENABLE_CMD_COMPLETE_AUDIT`
- Scope: controls emission of `cmd_complete` audit event in `BaseConnection#run_command`
- Default: enabled when unset
- Disable values: `0`, `false`, `no`, `off`
- Enable values: unset, `1`, `true`, `yes`, `on`

### Local validation output

Lint (changed Ruby files):

```text
Inspecting 2 files
..

2 files inspected, no offenses detected
CHEFSTYLE_EXIT:0
```

Default mode (flag unset):

```text
Run options: --seed 47056

# Running:

..............................

Finished in 0.010436s, 2874.6645 runs/s, 6324.2620 assertions/s.

30 runs, 66 assertions, 0 failures, 0 errors, 0 skips
```

OFF mode (`TRAIN_ENABLE_CMD_COMPLETE_AUDIT=0`):

```text
Run options: --seed 30736

# Running:

..............................

Finished in 0.009965s, 3010.5368 runs/s, 6623.1810 assertions/s.

30 runs, 66 assertions, 0 failures, 0 errors, 0 skips
```

### Contract evidence
- Default/ON behavior: `cmd_complete` event remains emitted.
- OFF behavior: `cmd_complete` event suppressed while `cmd` start event still emits.
- Process-level mode is explicitly validated by test logic in `connection_test.rb`.

### Rollback
Revert commit touching:
- `lib/train/plugins/base_connection.rb`
- `test/unit/plugins/connection_test.rb`
- `docs/audit_log.md`
- `.copilot-track/walk/ex13/plan.md`
- `.copilot-track/walk/ex13/notes.md`
