## Plan

Exercise: ex8

### Goal / Outcome
Improve baseline security hygiene by adding a dedicated CI secret scan, handling at least one scanner finding, and documenting the process.

### Current state assessment
- No dedicated secret scan workflow in this repo under `.github/workflows/`.
- Existing CI stubs include optional TruffleHog inputs in `ci-main-pull-request-stub.yml`, but no focused repository-level secret-check workflow.
- `SECURITY.md` only contains vulnerability reporting policy and no secret scanning guidance.

### Implementation steps
1. Add dedicated CI secret scan workflow using TruffleHog and follow the existing `ci-main-pull-request` style for triggers/permissions.
2. Run scanner locally (or CI-only fallback) to collect findings.
3. Remediate one finding by excluding known-safe test fixture content via scanner ignore config with documented rationale.
4. Update security documentation with scan process and local run command.
5. Record evidence and rollback instructions.

### Files to change
- `.github/workflows/secret-scan.yml` (new)
  - Add pull_request/push/workflow_dispatch secret scanning job.
  - Run TruffleHog against repository files.
  - Keep scope small; avoid submodule/vendor scanning.
- `.trufflehogignore` (new)
  - Add minimal ignore rules for known-safe fixture/test artifacts and VCS internals.
- `SECURITY.md`
  - Add a "Secret Scanning" section describing CI and local verification.
- `.copilot-track/walk/ex8/notes.md` (new)
  - Capture findings, remediation/ignore rationale, command output summary, rollback.

### Test strategy
- Security scan validation:
  - Run TruffleHog locally via Docker if binary is unavailable.
- Regression checks:
  - No runtime code changes expected; run a targeted sanity test command if needed:
    - `bundle exec ruby -Ilib:test test/unit/train_test.rb`

### Evidence to capture (coverage/contract)
- Scanner execution output before/after config/remediation.
- CI workflow config diff proving scan step exists.
- Documented rationale for any ignore entries (known-safe test fixtures).
- Coverage/contract note:
  - Change is CI/security policy only; no product behavior contracts changed.
  - Existing test suite remains contract guard.

### Rollback
- Revert commit(s) introducing:
  - `.github/workflows/secret-scan.yml`
  - `.trufflehogignore`
  - `SECURITY.md` secret scanning section
- If needed, temporarily disable workflow by removing the file in a revert commit.

### Troubleshooting
- If scanner returns many false positives, tighten allowlist by exact path and keep justification in `.copilot-track/walk/ex8/notes.md`.
- If local scanner install is unavailable, rely on CI-only workflow as evidence and document that fallback.
