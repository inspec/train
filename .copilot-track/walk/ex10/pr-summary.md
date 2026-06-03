## Summary
- Added a non-blocking coverage evidence workflow: `.github/workflows/coverage-summary.yml`.
- Added summary generator script: `contrib/write_coverage_summary.rb`.
- Updated `README.md` with instructions for where to view advisory coverage output in GitHub Actions.
- Added ex10 plan and evidence notes under `.copilot-track/walk/ex10/`.

## What This Changes
- Introduces an advisory CI job that runs coverage and writes results to `GITHUB_STEP_SUMMARY`.
- Keeps delivery unblocked by design:
  - coverage step uses `continue-on-error: true`
  - summary step runs with `if: always()`

## Evidence
Local validation command:

```bash
CI_ENABLE_COVERAGE=1 bundle exec rake test > /tmp/ex10-coverage.out
ruby contrib/write_coverage_summary.rb \
  --coverage-file coverage/.last_run.json \
  --test-output /tmp/ex10-coverage.out \
  --summary-file /tmp/ex10-summary.md \
  --threshold 80 \
  --command "CI_ENABLE_COVERAGE=1 bundle exec rake test" \
  --step-outcome success
cat /tmp/ex10-summary.md
```

Observed output:
- Coverage: 83.76%
- Soft gate: meets 80.00% threshold
- Test summary: 744 runs, 1237 assertions, 0 failures, 0 errors, 0 skips

## Acceptance Mapping
- Evidence visible in CI output: yes (job summary markdown)
- CI remains non-blocking: yes
- Instructions documented: yes (`README.md`)

## Rollback
Revert commit(s) touching:
- `.github/workflows/coverage-summary.yml`
- `contrib/write_coverage_summary.rb`
- `README.md`
- `.copilot-track/walk/ex10/*`
