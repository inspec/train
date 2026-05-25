## Plan

Exercise: ex6

### Goal / Outcome
Introduce a safe, measurable performance improvement by optimizing one identified hotspot and capturing before/after evidence with no behavior regression.

### Candidate bottleneck
- Function: `Train.target_config` in `lib/train.rb`
- Hot section: string-key to symbol-key normalization currently mutates hash via `conf.keys.each` + `delete` + assignment.
- Why this is a candidate:
  - Runs on target/config parsing path.
  - Current approach performs extra hash mutations and allocations.
  - A single-pass rebuild can reduce hash churn while keeping existing precedence behavior intact.

### Proposed optimization
Replace manual key-symbolization loop with a single-pass hash rebuild:
- Before: iterate keys, `delete`, then reinsert as symbols.
- After: build a new symbol-keyed hash while preserving the existing behavior where string keys override symbol keys.

### Files to change (small/reviewable)
- `lib/train.rb`
  - Apply optimization in `Train.target_config`.
- `test/unit/train_test.rb`
  - Keep/extend tests to ensure behavior parity of symbolization and URI parsing.
- `.copilot-track/walk/ex6/notes.md` (new)
  - Store baseline and post-change timings plus test/lint outputs.

### Measurement plan (before/after proof)
Use simple timing proxy (no profiler required), run same workload before and after change:
- Benchmark target: repeated calls to `Train.target_config` with representative string-key configs.
- Command style: Ruby one-liner using `Process.clock_gettime` around N iterations.
- Capture:
  - elapsed seconds before
  - elapsed seconds after
  - percent delta

### Implementation sequence
1. Capture baseline timing for existing implementation.
2. Apply key-symbolization optimization in `lib/train.rb`.
3. Re-run timing with identical workload and capture after metrics.
4. Run behavior tests (targeted + broader as needed).
5. Run lint for changed Ruby files.
6. Record evidence and update PR summary notes.

### Test strategy
- Targeted unit test:
  - `bundle exec ruby -Ilib:test test/unit/train_test.rb`
- If needed for confidence:
  - `bundle exec rake test`
- Lint changed files:
  - `chefstyle lib/train.rb test/unit/train_test.rb`

### Evidence to capture (coverage/contract/perf)
- Baseline and after timing numbers for the same benchmark workload.
- Delta percentage and interpretation.
- Test results summary (runs/failures/errors/skips).
- Lint summary (offenses/no offenses).
- Safety statement: behavior parity validated by existing/updated tests.

### Acceptance mapping
- Optimization implemented: yes, in `lib/train.rb`.
- Before/after evidence included: yes, in ex6 notes and PR summary.
- No behavior regression: verified by tests and lint.

### Troubleshooting path
- If improvement is negligible, document null result with measured evidence and keep or drop change based on readability/risk.
- If tests fail, adjust implementation for parity before considering revert.
- If benchmark is noisy, increase iteration count and repeat 3 runs; report median.

### Risk and rollback
- Risk: low (internal refactor of key normalization logic).
- Rollback: revert ex6 optimization commit(s) touching `lib/train.rb` and related test adjustments.
