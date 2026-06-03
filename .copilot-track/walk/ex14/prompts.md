## ex14 prompts and output

Date: 2026-05-27

### Primary prompt
Goal / Outcome: Improve quality enforcement in a scoped manner. Increase strictness on one path and gate it in CI with documented suppressions.

Steps
- Choose one directory or module to increase static analysis strictness (e.g., enable strict mode, add a stricter lint rule, or increase type checking level).
- Apply the stricter configuration and fix high-signal findings. For findings you choose not to fix, add a suppression with a comment explaining why.
- Add a CI step that enforces the stricter rules for that specific path only, so it does not block unrelated code.
- Document all suppressions and the rationale in the PR.

Acceptance
- Strictness increased for a defined path
- High-signal findings resolved
- Suppressions documented

Troubleshooting
- If enabling strict mode produces hundreds of errors, narrow scope to a single file or a smaller subset of rules.
- If the CI platform does not support path-scoped checks, run the stricter config locally and document the process.

Plan-first requirement
- Create a plan first: list steps and files to change.
- Then produce diffs file-by-file.
- Include: test strategy, evidence to capture (coverage/contract), and rollback.
- Keep scope small and reviewable.
- Avoid submodules/vendor folders.

### Output / Evidence
Implementation outcome:
- Introduced path-scoped strict RuboCop config at `.rubocop-strict-plugins.yml`.
- Increased strictness only for `lib/train/plugins/base_connection.rb` with:
  - `Style/RedundantInterpolation`
  - `Metrics/MethodLength` (Max 20)
- Resolved high-signal findings by replacing redundant interpolation with explicit `to_s` in audit payload fields.
- Added documented suppression for `Metrics/MethodLength` around `run_command` with compatibility rationale.
- Added path-scoped CI gate at `.github/workflows/strict-lint-plugins.yml`.

Validation output:

```text
$ bundle exec rubocop -c .rubocop-strict-plugins.yml lib/train/plugins/base_connection.rb
Inspecting 1 file
.

1 file inspected, no offenses detected
```

```text
$ bundle exec chefstyle lib/train/plugins/base_connection.rb
Inspecting 1 file
.

1 file inspected, no offenses detected
```

```text
$ ruby -e 'require "yaml"; YAML.load_file(".github/workflows/strict-lint-plugins.yml"); puts "YAML_OK"'
YAML_OK
```

Suppression rationale:
- `run_command` centralizes arity compatibility handling for external transport plugins.
- Splitting/refactoring this method solely to satisfy method-length would increase compatibility risk now.
- Suppression is intentionally narrow and inline-documented.

Rollback:
- Revert commit touching:
  - `.rubocop-strict-plugins.yml`
  - `lib/train/plugins/base_connection.rb`
  - `.github/workflows/strict-lint-plugins.yml`
  - `.copilot-track/walk/ex14/plan.md`
  - `.copilot-track/walk/ex14/notes.md`
