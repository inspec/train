## Plan

Exercise: ex3

### Goal / Outcome
Practice structured multi-file planning and controlled implementation by executing a small refactor across 2-4 files with tests and lint passing.

### Refactor opportunity
Extract duplicated command-invocation selection logic used by container transports into a shared helper method to reduce repetition and improve readability.

### Files to change (max 4)
- `lib/train/transports/docker.rb` - refactor `run_command_via_connection` to use shared helper for command invocation.
- `lib/train/transports/podman.rb` - refactor `run_command_via_connection` similarly for consistency.
- `lib/train/transports/helpers/container_command_helper.rb` - add helper module encapsulating command wrapper + shell/cmd invocation selection.
- `test/unit/transports/helpers/container_command_helper_test.rb` - add focused unit tests for helper behavior.

### Why these files
- Docker and Podman currently implement highly similar invocation paths.
- A helper centralizes behavior, reducing drift and making future fixes safer.
- A dedicated helper test keeps refactor risk low and verifies behavior independent of transport wiring.

### Expected impact
- No behavioral change to command execution outcomes.
- Improved maintainability and reduced duplication.
- Better testability of invocation decision logic.

### Implementation sequence
1. Create helper module and define API used by both transports.
2. Update Docker transport to delegate invocation logic to helper.
3. Update Podman transport to delegate invocation logic to helper.
4. Add helper unit tests (success paths and Windows/non-Windows invocation selection).
5. Review diffs file-by-file before finalizing.

### Diff review workflow
- Produce and review each file diff after edit.
- Validate no unrelated formatting/reordering changes.
- Keep public APIs stable unless explicitly required.

### Validation strategy
- Test command: `bundle exec rake test`
- Lint command: `chefstyle && chefstyle -a`
- Re-run tests if lint auto-fixes change Ruby files.

### Evidence to capture (for PR)
- Plan link/path: `.copilot-track/walk/ex3/plan.md`
- Test output summary: runs/failures/errors/skips from full suite.
- Lint output summary: clean/no offenses (or fixed offenses + recheck).
- Brief note confirming behavior-preserving refactor.

### Acceptance mapping
- Plan included in PR: include this plan path in PR body.
- Multiple files modified: target 3-4 files listed above.
- Tests remain green: required gate before PR.

### Troubleshooting
- If scope grows beyond 4 files, narrow to helper + one transport + tests first.
- If tests fail, diagnose failing expectations and adjust helper integration before any revert.
- If lint auto-corrections alter behavior-critical lines, rerun tests immediately.

### Risk and rollback
- Risk: low to medium (internal refactor touching command invocation paths).
- Rollback: revert the ex3 refactor commit(s) affecting the listed files only.
