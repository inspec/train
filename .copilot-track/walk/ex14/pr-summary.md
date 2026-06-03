## Summary
- Increased static analysis strictness in a single scoped path.
- Added a path-specific CI gate so unrelated code is not blocked.
- Fixed high-signal findings and documented one justified suppression.

## Scope
- Target path: `lib/train/plugins/base_connection.rb`
- Strict config: `.rubocop-strict-plugins.yml`
- CI gate: `.github/workflows/strict-lint-plugins.yml`

## What changed
- Added `.rubocop-strict-plugins.yml` with `DisabledByDefault: true` and two enabled cops:
  - `Style/RedundantInterpolation`
  - `Metrics/MethodLength` (`Max: 20`)
- Updated `lib/train/plugins/base_connection.rb`:
  - `"#{cmd}"` -> `cmd.to_s`
  - `"#{path}"` -> `path.to_s`
  - Added scoped `Metrics/MethodLength` suppression around `run_command` with compatibility rationale.
- Added `.github/workflows/strict-lint-plugins.yml`:
  - Runs strict lint only when scoped files are changed.

## Validation
- `bundle exec rubocop -c .rubocop-strict-plugins.yml lib/train/plugins/base_connection.rb`
  - 1 file inspected, no offenses.
- `bundle exec chefstyle lib/train/plugins/base_connection.rb`
  - 1 file inspected, no offenses.
- Workflow YAML parse
  - `YAML_OK`

## Suppressions and rationale
- Suppression: `Metrics/MethodLength` for `run_command` only.
- Rationale: method contains compatibility-sensitive arity dispatch for external plugins; refactor risk currently outweighs strictness gain.

## Acceptance mapping
- Strictness increased for defined path: yes.
- High-signal findings resolved: yes.
- Suppressions documented: yes.

## Risk & Rollback
- Risk: low; runtime behavior is unchanged, enforcement is scoped.
- Rollback: revert commit `c37e159`.

## Track
- Level: Walk
- Exercise: ex14
