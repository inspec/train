## Plan

Exercise: ex7

### Goal / Outcome
Safely improve maintainability by applying one minor dependency upgrade and validating no regressions.

### Selected dependency
- Gem: `rake`
- Current: `13.3.1`
- Target: `13.4.2`
- Reason: direct dev/test dependency in `Gemfile` with existing constraint `~> 13.0`, low runtime risk, narrow lockfile impact.

### Steps
1. Capture current state (`bundle outdated`, lockfile version).
2. Upgrade only `rake` using Bundler.
3. Review lockfile diff to ensure scope stays small.
4. Run full test suite (`bundle exec rake test`).
5. Run lint on changed files if needed.
6. Record rationale, evidence, and rollback instructions.

### Files to change
- `Gemfile`
  - Raise `rake` constraint from `~> 13.0` to `~> 13.4`.
- `Gemfile.lock` (local only, not tracked)
  - Bundler resolves to `rake 13.4.2` for local validation.
- `.copilot-track/walk/ex7/notes.md` (new)
  - Capture upgrade rationale, commands, test output summary, rollback command.
- `.copilot-track/walk/ex7/pr-summary.md` (new)
  - PR-ready summary with evidence.

### Test strategy
- Full suite:
  - `bundle exec rake test`
- Optional targeted sanity if full suite fails due environment:
  - `bundle exec ruby -Ilib:test test/unit/train_test.rb`

### Evidence to capture (coverage/contract)
- Dependency evidence:
  - `bundle outdated` output showing prior state.
  - `Gemfile` diff showing the minor constraint bump.
  - local lockfile verification (`rake 13.4.2`) for execution context.
- Verification evidence:
  - full test suite result (runs/failures/errors/skips).
- Coverage/contract note:
  - This dependency-only change does not alter product contracts.
  - Existing unit/integration suite serves as regression contract guard.

### Rollback
- Revert this branch commit, or explicitly downgrade:
  - set `Gemfile` back to `gem "rake", "~> 13.0"`
  - then run `bundle install`.

### Troubleshooting
- If upgrade introduces widespread failures, rollback and select another low-risk minor update.
- If no minor update is available under constraints, document state and consider patch-only update.
