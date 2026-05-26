## ex9 observability notes

Date: 2026-05-26

### Instrumentation added
- Added `cmd_complete` audit-log event in `Train::Plugins::Transport::BaseConnection#run_command`.
- Event includes:
  - `command`
  - `duration_ms`
  - `cache_hit`
  - `exit_status` (when available)
  - existing `user` / `hostname` metadata

### Verification commands

Targeted unit tests:

```bash
bundle exec ruby -Ilib:test test/unit/plugins/connection_test.rb
```

Result:
- 28 runs, 60 assertions, 0 failures, 0 errors, 0 skips

Local output verification:

```bash
rm -f /tmp/train-ex9-audit.log
bundle exec ruby -Ilib -e 'require "train"; t = Train.create("local", enable_audit_log: true, audit_log_location: "/tmp/train-ex9-audit.log", audit_log_app_name: "train"); c = t.connection; c.run_command("echo ex9")'
tail -n 5 /tmp/train-ex9-audit.log
```

Sample output includes:

```json
{"timestamp":"2026-05-26 15:00:44 +0530","app":"train","type":"cmd_complete","command":"echo ex9","duration_ms":18.63,"cache_hit":false,"exit_status":0}
```

Ruby lint on changed code files:

```bash
chefstyle lib/train/plugins/base_connection.rb test/unit/plugins/connection_test.rb
```

Result:
- 2 files inspected, no offenses detected

### Where to view in production/staging
- View `cmd` and `cmd_complete` events in the configured audit log file path (`audit_log_location`) for the application embedding Train.

### Coverage/contract note
- This is additive observability only; command execution behavior is unchanged.
- Existing test suite continues to enforce behavior contracts.

### Rollback
- Revert commit(s) touching:
  - `lib/train/plugins/base_connection.rb`
  - `test/unit/plugins/connection_test.rb`
  - `docs/audit_log.md`
  - `.copilot-track/walk/ex9/*`
