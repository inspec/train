## Plan

Exercise: ex15

### Goal / Outcome
Add a safer, opt-in resilience improvement for local connection pipe recovery that does not change default behavior.

### Scope
- Keep existing `WindowsPipeRunner#run_command` behavior unchanged by default.
- Add one additional retry attempt with backoff only when an env flag is enabled.
- Add failure tests for both default and opt-in paths.

### Call site
- `Train::Transports::Local::Connection::WindowsPipeRunner#run_command`
  - Existing behavior: one recovery retry on `Errno::EPIPE`.
  - New behavior: optional second recovery retry with backoff when flag is enabled.

### Steps
1. Add opt-in env toggle and backoff parsing in `local.rb`.
2. Integrate optional second retry path after existing retry failure.
3. Add tests for:
   - default mode: second `Errno::EPIPE` still raises
   - opt-in mode: second retry with backoff can succeed
4. Capture tuning and rollback guidance in notes.

### Files to change
- `lib/train/transports/local.rb`
- `test/unit/transports/local_test.rb`
- `.copilot-track/walk/ex15/notes.md`

### Test strategy
- Lint changed Ruby files:
  - `bundle exec chefstyle lib/train/transports/local.rb test/unit/transports/local_test.rb`
- Run focused tests:
  - `bundle exec ruby -Itest test/unit/transports/local_test.rb`

### Evidence to capture (coverage/contract)
- Test output showing all local transport tests pass.
- Explicit test evidence for default and opt-in paths.

### Tuning parameters
- `TRAIN_LOCAL_PIPE_EXTRA_RETRY` (`1|true|yes|on` to enable)
- `TRAIN_LOCAL_PIPE_RETRY_BACKOFF_SECONDS` (default `0.05`)

### Rollback
- Revert commit touching:
  - `lib/train/transports/local.rb`
  - `test/unit/transports/local_test.rb`
  - `.copilot-track/walk/ex15/plan.md`
  - `.copilot-track/walk/ex15/notes.md`
