## ex13 prompts

Date: 2026-05-27

### Primary prompt
Goal / Outcome: Reduce risk for behavior changes. Document flag lifecycle and validate both ON and OFF modes in CI or locally.

Steps
- Identify an existing feature flag or introduce a simple one (e.g., environment variable or config toggle) for a safe behavior change.
- Document the flag lifecycle: creation, default state, how to enable, how to disable, and when to remove.
- Validate both ON and OFF states by running tests in each mode. If CI matrix testing is feasible, add both configurations.
- Include the validation output for both states in the PR.

Acceptance
- Flag lifecycle documented
- ON/OFF validated
- Tests updated if required

Troubleshooting
- If the repo has no feature flag system, use a simple environment variable and document how to set/unset it.
- If CI matrix testing is too complex, document the manual validation steps and include output from both local runs.

Plan-first requirement
- Create a plan first with steps and files to change.
- Then produce file-by-file diffs.
- Include test strategy, evidence to capture (coverage/contract), and rollback.
- Keep scope small and reviewable.
- Avoid submodules/vendor folders.

### Output / Evidence

Implementation outcome:
- Added feature flag `TRAIN_ENABLE_CMD_COMPLETE_AUDIT` to control `cmd_complete` audit event emission.
- Default behavior remains unchanged (event is emitted when flag is unset).
- Added ON/OFF test coverage and process-level mode validation.
- Documented feature flag lifecycle in audit log docs.

Files changed:
- `lib/train/plugins/base_connection.rb`
- `test/unit/plugins/connection_test.rb`
- `docs/audit_log.md`
- `.copilot-track/walk/ex13/plan.md`
- `.copilot-track/walk/ex13/notes.md`

Validation output:

```text
Inspecting 2 files
..

2 files inspected, no offenses detected
CHEFSTYLE_EXIT:0
```

```text
Run options: --seed 47056

# Running:

..............................

Finished in 0.010436s, 2874.6645 runs/s, 6324.2620 assertions/s.

30 runs, 66 assertions, 0 failures, 0 errors, 0 skips
```

```text
Run options: --seed 30736

# Running:

..............................

Finished in 0.009965s, 3010.5368 runs/s, 6623.1810 assertions/s.

30 runs, 66 assertions, 0 failures, 0 errors, 0 skips
```

Contract evidence:
- ON/default: `cmd_complete` event is present.
- OFF mode: `cmd_complete` is suppressed.
- Both modes: command start `cmd` event remains present.

Rollback:
- Revert commit touching:
	- `lib/train/plugins/base_connection.rb`
	- `test/unit/plugins/connection_test.rb`
	- `docs/audit_log.md`
	- `.copilot-track/walk/ex13/plan.md`
	- `.copilot-track/walk/ex13/notes.md`
