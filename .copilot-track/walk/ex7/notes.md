## ex7 dependency upgrade notes

Date: 2026-05-25

### Goal
Safely improve maintainability with a single minor dependency upgrade and verify no regressions.

### Dependency selection
- Package manager: Bundler
- Outdated scan command: `bundle outdated`
- Selected gem: `rake`
- Before: `13.3.1`
- After: `13.4.2`
- Selection rationale:
  - direct dependency in test tooling (`Gemfile`)
  - minor-line bump within the same major version
  - lower risk than large transitive/runtime upgrades

### Applied change
- Updated `Gemfile` constraint:
  - from `gem "rake", "~> 13.0"`
  - to `gem "rake", "~> 13.4"`
- Ran `bundle install` to resolve dependencies locally.
- Local lock context confirms `rake 13.4.2` is used.

### Test strategy
- Full test suite (required):
  - `bundle exec rake test`
- Scope note:
  - This change only affects dependency versioning and does not alter feature contracts directly.
  - Existing tests act as regression contract coverage.

### Test evidence
Command:

```bash
bundle exec rake test
```

Result summary:
- Finished in 2.327440s
- 742 runs
- 1221 assertions
- 0 failures
- 0 errors
- 0 skips

### Breakages and fixes
- No test breakages observed.
- No product code changes required.

### Rollback
- Preferred: revert the ex7 dependency-upgrade commit.
- Manual rollback:
  1. Change `Gemfile` back to `gem "rake", "~> 13.0"`
  2. Run `bundle install`
  3. Re-run `bundle exec rake test`

### Troubleshooting guidance used
- If this upgrade had caused widespread failures, fallback would be to rollback and select a lower-risk minor candidate.
- If no suitable minor upgrades were available, next option would be a documented patch-level update.
