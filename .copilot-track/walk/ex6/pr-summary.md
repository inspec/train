## Summary
- Optimized `Train.target_config` key normalization in `lib/train.rb` by replacing delete-and-reinsert symbolization with a single-pass hash rebuild.
- Preserved existing precedence semantics where string keys override symbol keys for the same logical field.
- Added a regression test in `test/unit/train_test.rb` to lock the precedence behavior.

## Performance Evidence
- Benchmark command:

```bash
bundle exec ruby -Ilib -e 'require "train"; input = {"target"=>"ssh://user:pass@host.com:123/path","backend"=>"ssh","host"=>"host.com","user"=>"user","password"=>"pass","port"=>123,"path"=>"/path"}; n=200000; 3.times do |i|; t0=Process.clock_gettime(Process::CLOCK_MONOTONIC); n.times { Train.target_config(input) }; t1=Process.clock_gettime(Process::CLOCK_MONOTONIC); puts "run#{i+1}=#{(t1-t0).round(6)}s"; end'
```

- Baseline runs: 2.947110s, 2.918756s, 2.949676s
- After runs: 2.892206s, 2.867399s, 2.867159s
- Median improvement: 0.079711s over 200000 iterations
- Relative improvement: 2.70%

## Validation
- `bundle exec ruby -Ilib:test test/unit/train_test.rb`
  - 27 runs, 92 assertions, 0 failures, 0 errors, 0 skips
- `chefstyle lib/train.rb test/unit/train_test.rb`
  - 2 files inspected, no offenses detected

## Risk / Rollback
- Risk is low because the change is limited to internal key normalization logic and is covered by a focused regression test.
- Rollback path: revert the ex6 commit touching `lib/train.rb` and `test/unit/train_test.rb`.
