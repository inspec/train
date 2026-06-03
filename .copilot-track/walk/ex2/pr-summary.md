## Summary
- Added local coverage documentation so contributors can reliably produce coverage evidence.
- Clarified that `bundle install` is a prerequisite before running `bundle exec` test commands.
- Updated PR guidance to require reporting total coverage percentage with the exact command used.
- Captured a verified local coverage run for auditability.
- This work was completed with AI assistance following Progress AI policies.

## Plan
- Coverage visibility and reviewer clarity plan tracked in `.copilot-track/walk/ex2/plan.md`.

## Files/paths touched
- `README.md`
- `.github/pr-template-instructions.md`
- `.copilot-track/walk/README.md`
- `.copilot-track/walk/ex2/notes.md`

## Evidence
- Tests/logs/metrics: `CI_ENABLE_COVERAGE=1 bundle exec rake test` -> `737 runs, 1210 assertions, 0 failures, 0 errors, 0 skips`
- Coverage: `83.66% (2130 / 2546)` using `CI_ENABLE_COVERAGE=1 bundle exec rake test`
- Coverage report output: `coverage/`

## Risk & Rollback
- Risk: low (documentation/process-only changes; no runtime behavior changes).
- Rollback: revert commit `1bf5375`.

## Review Focus
- Verify coverage instructions in `README.md` are accurate and copy-paste runnable.
- Confirm PR Evidence guidance now requires total percentage + exact command.
- Confirm coverage evidence in `.copilot-track/walk/ex2/notes.md` matches the command output.

## Track
- Level: Walk
- Exercise: ex2
