## ex15 notes

Date: 2026-05-27

### Goal
Introduce a safer reliability improvement for local connection pipe failures with no default behavior change.

### What changed
- Kept existing `WindowsPipeRunner#run_command` default recovery logic intact.
- Added optional extra retry path gated by environment variable.
- Added short configurable backoff before the optional retry.
- Added tests for default and opt-in behavior.

### Tuning parameters
- `TRAIN_LOCAL_PIPE_EXTRA_RETRY`
  - Enables extra retry when set to one of: `1`, `true`, `yes`, `on`.
  - Default: disabled (unset / any other value).
- `TRAIN_LOCAL_PIPE_RETRY_BACKOFF_SECONDS`
  - Backoff before extra retry.
  - Default: `0.05` seconds.
  - Invalid/negative values fall back to `0.05`.

### Validation output
Lint:

```text
Inspecting 2 files
..

2 files inspected, no offenses detected
```

Tests:

```text
Run options: --seed 13469

# Running:

...................................

Finished in 0.119072s, 293.9398 runs/s, 881.8194 assertions/s.

35 runs, 105 assertions, 0 failures, 0 errors, 0 skips
```

### Contract evidence
- Default mode: behavior unchanged from previous implementation (single recovery retry on `Errno::EPIPE`).
- Opt-in mode: one additional recovery retry is attempted with backoff.

### Rollback
Revert commit touching:
- `lib/train/transports/local.rb`
- `test/unit/transports/local_test.rb`
- `.copilot-track/walk/ex15/plan.md`
- `.copilot-track/walk/ex15/notes.md`
