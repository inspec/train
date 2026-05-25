# ex2 Coverage Run Notes

## Environment
- Ruby: 3.1.7
- Branch: `vasundhara-walk-ex2`

## Coverage command
```bash
CI_ENABLE_COVERAGE=1 bundle exec rake test
```

## Result summary
- Test summary: `737 runs, 1210 assertions, 0 failures, 0 errors, 0 skips`
- Coverage output directory: `coverage/`
- Line coverage: `83.66% (2130 / 2546)`

## PR summary snippet
- `Coverage: 83.66% (CI_ENABLE_COVERAGE=1 bundle exec rake test)`

## Notes
- Coverage is enabled in `test/helper.rb` when `CI_ENABLE_COVERAGE` is set.
- If coverage appears unexpectedly low, re-run the full `rake test` suite and avoid single-file subsets.
