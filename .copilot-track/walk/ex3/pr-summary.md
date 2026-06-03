## Summary
- Refactored duplicated command invocation logic from Docker and Podman transports into a shared helper.
- Kept behavior equivalent while reducing duplication and aligning container transport execution flow.
- Added focused unit tests for the helper to verify shell/cmd selection and command-wrapper application.
- This work was completed with AI assistance following Progress AI policies.

## Plan
- Plan path: `.copilot-track/walk/ex3/plan.md`

## Files/paths touched
- `lib/train/transports/docker.rb`
- `lib/train/transports/podman.rb`
- `lib/train/transports/helpers/container_command_helper.rb`
- `test/unit/transports/helpers/container_command_helper_test.rb`

## Evidence
- Focused test: `bundle exec ruby -Ilib:test test/unit/transports/helpers/container_command_helper_test.rb`
  - Result: `3 runs, 3 assertions, 0 failures, 0 errors, 0 skips`
- Full unit suite: `bundle exec rake test`
  - Result: `740 runs, 1213 assertions, 0 failures, 0 errors, 0 skips`
- Lint (changed files):
  - Command: `chefstyle lib/train/transports/docker.rb lib/train/transports/podman.rb lib/train/transports/helpers/container_command_helper.rb test/unit/transports/helpers/container_command_helper_test.rb`
  - Result: `4 files inspected, no offenses detected`

## Risk & Rollback
- Risk: low to medium (internal refactor in command invocation path for Docker/Podman transports).
- Rollback: revert commit `cd670e3`.

## Review Focus
- Confirm Docker and Podman still invoke commands identically after helper extraction.
- Confirm helper tests cover non-Windows, Windows, and wrapped-command paths.
- Confirm no API surface changes were introduced.

## Track
- Level: Walk
- Exercise: ex3
