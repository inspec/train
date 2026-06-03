## Summary
- Upgraded one minor dependency for maintainability: `rake`.
- Raised test-group `rake` constraint in `Gemfile` from `~> 13.0` to `~> 13.4`.
- Resolved dependencies with Bundler; local environment now uses `rake 13.4.2`.

## Why this upgrade
- `rake` is a direct project tooling dependency and a lower-risk upgrade target.
- The change stays within the same major version and keeps scope narrow and reviewable.

## Validation
- Full suite executed:

```bash
bundle exec rake test
```

- Result: 742 runs, 1221 assertions, 0 failures, 0 errors, 0 skips.

## Breakages
- None observed.
- No application code changes required.

## Rollback
- Revert this ex7 commit, or:
  1. Set `Gemfile` to `gem "rake", "~> 13.0"`
  2. Run `bundle install`
  3. Re-run `bundle exec rake test`
