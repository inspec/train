## Plan

Exercise: ex14

### Goal / Outcome
Improve quality enforcement in a scoped manner by increasing static-analysis strictness for a single path, resolving high-signal findings, documenting justified suppressions, and enforcing the scoped check in CI.

### Scoped path
- `lib/train/plugins/base_connection.rb`

### Approach
- Introduce a dedicated strict RuboCop config for only the scoped path.
- Enforce two stricter checks on this path:
  - `Style/RedundantInterpolation` (high-signal readability/perf)
  - `Metrics/MethodLength` with stricter threshold for this file
- Fix high-signal findings from redundant interpolation.
- Add a targeted suppression for `run_command` method length, with rationale comment.
- Add CI workflow that runs strict config only for this path to avoid blocking unrelated files.

### Steps
1. Add strict RuboCop config file scoped to `lib/train/plugins/base_connection.rb`.
2. Update `base_connection.rb` to resolve strict findings and add justified suppression.
3. Add path-scoped CI workflow for strict lint enforcement.
4. Capture evidence in ex14 notes including suppression rationale and local command output.

### Files to change
- `.rubocop-strict-plugins.yml` (new)
- `lib/train/plugins/base_connection.rb`
- `.github/workflows/strict-lint-plugins.yml` (new)
- `.copilot-track/walk/ex14/notes.md` (new)

### Test strategy
- Local strict lint run:
  - `bundle exec rubocop -c .rubocop-strict-plugins.yml lib/train/plugins/base_connection.rb`
- Baseline lint sanity for changed Ruby file:
  - `bundle exec chefstyle lib/train/plugins/base_connection.rb`
- YAML parse validation for workflow file.

### Evidence to capture (coverage/contract)
- Strict lint output showing zero offenses for scoped path.
- Suppression rationale recorded in notes and PR summary.
- Contract note: runtime behavior unchanged (lint/docs/CI-only enforcement).

### Rollback
- Revert commit touching:
  - `.rubocop-strict-plugins.yml`
  - `lib/train/plugins/base_connection.rb`
  - `.github/workflows/strict-lint-plugins.yml`
  - `.copilot-track/walk/ex14/notes.md`

### Out of scope
- No repo-wide lint strictness increase.
- No changes to submodules/vendor folders.
