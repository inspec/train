## Plan

Exercise: ex2

### What changes and why
Improve reviewer confidence by making test coverage visible and reproducible. The exercise will identify how coverage is produced in this repository, run coverage once to capture a real percentage, and document both the command and expected output location so coverage can be included in PR summaries consistently.

### Files to change
- `README.md` - add a "Coverage" section with local run instructions and output location.
- `.copilot-track/walk/ex2/notes.md` - capture the verified local coverage run output (command + percent).
- `.github/pr-template-instructions.md` - add a short reminder in Evidence to include total coverage percentage.

### Scope guardrails
- Keep changes to documentation and PR guidance only.
- Do not modify runtime code under `lib/`.
- Do not touch vendor/submodule paths.

### Sequence of steps
1. Identify the test runner and coverage tool from repo configuration (`Gemfile`, `test/helper.rb`, `Rakefile`, and existing docs).
2. Determine the exact coverage command. If coverage is not enabled by default, define the minimal command to enable/report it.
3. Run the command locally and capture key output: total coverage percentage, output artifact path, and pass/fail test summary.
4. Update `README.md` with a concise "How to run coverage" section.
5. Update PR guidance in `.github/pr-template-instructions.md` so PR Evidence includes total coverage percentage.
6. Record the verified run output in `.copilot-track/walk/ex0/notes.md` for traceability.

### Test strategy
- Primary validation: execute coverage command end-to-end locally.
- Confirm command exits successfully and produces a coverage percentage.
- Confirm documentation commands are copy-paste runnable.
- If local execution is blocked, use CI output as fallback evidence and document the limitation.

### Evidence to capture (coverage/contract)
- Coverage command used (exact command string).
- Coverage percentage (single total percentage from tool output).
- Test execution summary (runs/failures/errors/skips).
- Artifact location, if generated (for example coverage report directory/file).
- PR summary line format: `Coverage: <NN.NN>% (command: <...>)`.

### Acceptance mapping
- Coverage instructions documented: via `README.md` section.
- Coverage percentage included in PR description: via PR template guidance update and run evidence.
- Coverage command verified locally or in CI: via captured command output in notes.

### Troubleshooting path
- If no test framework or coverage tool is available, document findings and add a backlog recommendation for a lightweight option (SimpleCov + Minitest).
- If coverage appears unexpectedly low, rerun full suite (not subset), verify test command and environment, and note assumptions.

### Risk and rollback
- Risk: low (documentation and guidance changes only).
- Rollback: revert only the modified docs (`README.md`, `.github/pr-template-instructions.md`, `.copilot-track/walk/ex2/*`).
