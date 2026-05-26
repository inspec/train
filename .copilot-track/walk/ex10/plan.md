## Plan

Exercise: ex10

### Goal / Outcome
Surface validation evidence in CI without blocking delivery by adding a soft coverage gate and GitHub Actions job summary.

### Current state assessment
- Coverage already exists via `SimpleCov` when `CI_ENABLE_COVERAGE=1`.
- Local coverage output includes a stable `.last_run.json` file with total line coverage.
- The main CI PR stub delegates to a shared workflow, so the smallest repo-local change is a separate advisory workflow.

### Implementation steps
1. Add a dedicated advisory coverage workflow for pull requests, pushes to `main` / `release/**`, and manual dispatch.
2. Run `bundle install` and `CI_ENABLE_COVERAGE=1 bundle exec rake test` in a non-blocking step.
3. Parse coverage percent from `coverage/.last_run.json` and test outcome from the captured test log.
4. Write a markdown summary to `GITHUB_STEP_SUMMARY` showing:
   - coverage percentage
   - soft threshold comparison (80%)
   - test result status
   - exact command used
5. Document where contributors can find the advisory summary in CI.
6. Record local verification evidence and rollback guidance.

### Files to change
- `.github/workflows/coverage-summary.yml` (new)
  - Advisory workflow that always writes a job summary.
  - Coverage/test step must not block merges on failure.
- `contrib/write_coverage_summary.rb` (new)
  - Generate consistent markdown from coverage JSON and test log.
- `README.md`
  - Document the advisory CI coverage summary and where to view it.
- `.copilot-track/walk/ex10/notes.md` (new)
  - Store local verification output and summary sample.

### Test strategy
- Local verification of the workflow logic:
  - `CI_ENABLE_COVERAGE=1 bundle exec rake test`
  - `ruby contrib/write_coverage_summary.rb ...`
- Optional sanity check:
  - inspect generated markdown summary content.

### Evidence to capture (coverage/contract)
- Coverage percentage from `.last_run.json`.
- Generated markdown summary content.
- Confirmation that the workflow is advisory only (`continue-on-error` on validation step).
- Coverage/contract note:
  - This change only affects CI evidence reporting, not runtime behavior.

### Rollback
- Revert commit(s) touching:
  - `.github/workflows/coverage-summary.yml`
  - `contrib/write_coverage_summary.rb`
  - `README.md`
  - `.copilot-track/walk/ex10/*`

### Troubleshooting
- If coverage artifact is missing, emit a warning summary instead of failing the workflow.
- If coverage tooling is unavailable in CI, the job should still complete and report the failure as advisory.
