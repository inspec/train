## ex14 notes

Date: 2026-05-27

### Goal
Increase static-analysis strictness in a scoped path and enforce it in CI without blocking unrelated code.

### Scoped strictness
- Scoped path: `lib/train/plugins/base_connection.rb`
- Strict config: `.rubocop-strict-plugins.yml`
- Added stricter checks for this path:
  - `Style/RedundantInterpolation`
  - `Metrics/MethodLength` (Max 20)

### High-signal findings resolved
- Replaced redundant interpolation with explicit `to_s`:
  - `command: "#{cmd}"` -> `command: cmd.to_s`
  - `path: "#{path}"` -> `path: path.to_s`

### Suppressions and rationale
- Suppressed `Metrics/MethodLength` on `run_command` with inline comment.
- Rationale: method centralizes transport arity compatibility handling for external plugins, so forced refactor here increases compatibility risk.

### CI gate
- Added path-scoped workflow: `.github/workflows/strict-lint-plugins.yml`
- Workflow runs only when scoped files change.
- Enforcement command:
  - `bundle exec rubocop -c .rubocop-strict-plugins.yml lib/train/plugins/base_connection.rb`

### Validation output

Scoped strict lint:

```text
Inspecting 1 file
.

1 file inspected, no offenses detected
```

Baseline lint sanity (`chefstyle`):

```text
Inspecting 1 file
.

1 file inspected, no offenses detected
```

Workflow YAML parse:

```text
YAML_OK
```

### Rollback
Revert commit touching:
- `.rubocop-strict-plugins.yml`
- `lib/train/plugins/base_connection.rb`
- `.github/workflows/strict-lint-plugins.yml`
- `.copilot-track/walk/ex14/plan.md`
- `.copilot-track/walk/ex14/notes.md`
