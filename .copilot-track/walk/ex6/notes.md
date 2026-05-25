## ex6 performance notes

Date: 2026-05-25

### Scope
Optimized key symbolization in `Train.target_config` (`lib/train.rb`) to reduce hash churn while preserving existing behavior.

### Benchmark workload
Command (before and after, identical workload):

```bash
bundle exec ruby -Ilib -e 'require "train"; input = {"target"=>"ssh://user:pass@host.com:123/path","backend"=>"ssh","host"=>"host.com","user"=>"user","password"=>"pass","port"=>123,"path"=>"/path"}; n=200000; 3.times do |i|; t0=Process.clock_gettime(Process::CLOCK_MONOTONIC); n.times { Train.target_config(input) }; t1=Process.clock_gettime(Process::CLOCK_MONOTONIC); puts "run#{i+1}=#{(t1-t0).round(6)}s"; end'
```

### Baseline (before)
- run1: 2.947110s
- run2: 2.918756s
- run3: 2.949676s
- median: 2.947110s

### After optimization
- run1: 2.892206s
- run2: 2.867399s
- run3: 2.867159s
- median: 2.867399s

### Delta
- Improvement: 0.079711s on median over 200000 iterations
- Relative improvement: 2.70%

Formula:

```text
(2.947110 - 2.867399) / 2.947110 = 0.0270
```

### Regression safety checks
- Targeted tests:

```bash
bundle exec ruby -Ilib:test test/unit/train_test.rb
```

Result: 27 runs, 92 assertions, 0 failures, 0 errors, 0 skips.

- Lint (changed files):

```bash
chefstyle lib/train.rb test/unit/train_test.rb
```

Result: 2 files inspected, no offenses detected.

### Notes
- Initial benchmark attempt including `keys` payload hit an unrelated existing edge in `group_keys_and_keyfiles` (`File.file?` constant lookup under `Train::File` scope). Benchmark payload was adjusted to isolate the symbolization hotspot.

### Rollback
If needed, revert only ex6 changes in:
- `lib/train.rb`
- `test/unit/train_test.rb`
