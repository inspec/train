### Testing Standards

#### Unit Testing Requirements
- **Framework**: Minitest (primary testing framework)
- **Coverage**: >80% is an *aspirational* target, **not** an enforced gate — see
  "Coverage Configuration" below for what the repo actually does.
- **Location**: Tests should be in `test/unit/` directories
- **Naming**: Test files should end with `_test.rb`
- **Mocking**: Use `mocha/minitest` for mocking external dependencies

#### Coverage Configuration
Coverage is **opt-in and ungated**. The real `test/helper.rb` only starts
SimpleCov when `CI_ENABLE_COVERAGE` is set, and configures **no**
`minimum_coverage` threshold and **no** `add_group`s:

```ruby
# test/helper.rb (actual)
if ENV["CI_ENABLE_COVERAGE"]
  require "simplecov"
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
  ])
  SimpleCov.start do
    add_filter "/test/"
  end
end
```

So there is no build-breaking coverage floor; running tests without
`CI_ENABLE_COVERAGE` does not measure coverage at all. Treat >80% as a goal to
aim for, not a CI gate. (A dedicated `.expeditor/coverage.pipeline.yml` runs the
coverage job in CI.)

#### Test Structure Example
```ruby
require "helper"

describe Train::Transports::MyTransport do
  let(:transport) { Train::Transports::MyTransport.new }
  
  describe "#connection" do
    it "establishes connection successfully" do
      conn = transport.connection
      _(conn).wont_be_nil
    end
    
    it "handles connection errors gracefully" do
      # Mock error conditions
      assert_raises(Train::TransportError) do
        transport.connection(invalid: true)
      end
    end
  end
end
```

---

## Testing the Train Gem Itself

> This section covers testing **the `inspec/train` codebase** (this repo). For
> authoring and testing a **standalone Train plugin** (in its own `train-<name>`
> gem repo), see the shared, cross-repo guide:
> [`context/shared/by-product/train/advice/testing-plugins.md`](../../shared/by-product/train/advice/testing-plugins.md).

### Layout & runner
- Unit tests live under `test/unit/**` and end in `_test.rb`. The default Rake
  task runs them: `Rake::TestTask` with pattern `test/unit/**/*_test.rb`
  (see `Rakefile`; `rake` alone runs `:test`).
- Mirror the `lib/` tree in `test/unit/` — e.g. `lib/train/file/remote/windows.rb`
  is covered by `test/unit/file/remote/windows_test.rb`. Existing subdirs:
  `test/unit/{extras,file,platforms,plugins,transports}`.
- Shared setup is `require "helper"` (`test/helper.rb`), which wires up Minitest,
  `mocha/minitest`, and SimpleCov.
- Integration/OS-specific suites are separate and gated:
  `rake test:docker`, `rake test:windows`, `rake test:ssh[user@server]`, and
  Test Kitchen (`test/integration`, `test/windows`). Do **not** require live
  targets for unit tests.

### What to cover
- **Options & defaults:** that `option` declarations, `:default`/`:coerce`, and
  `validate_options`/`validate_audit_log_options` behave (see `lib/train/options.rb`).
- **URI/target unpacking:** `Train.unpack_target_from_uri`, `target_config`, and
  `group_keys_and_keyfiles` edge cases (empty scheme `mock://`, query params,
  key vs key_file splitting).
- **Connection contract:** `run_command` arity dispatch, `file` caching, `upload`/
  `download`, and error raising (`Train::ClientError`/`TransportError`).
- **Platform detection:** add/extend specs in
  `test/unit/platforms/**` when touching `lib/train/platforms/**`.

### Prefer the Mock transport over live connections
Use `Train::Transports::Mock` to exercise connection/file/command logic without a
real backend:
```ruby
require "helper"
require "train/transports/mock"

describe "command handling" do
  let(:conn) { Train.create("mock", verbose: true).connection }

  it "returns a stubbed command result" do
    conn.mock_command("hostname", "web01", "", 0)
    result = conn.run_command("hostname")
    _(result.stdout).must_equal "web01"
    _(result.exit_status).must_equal 0
  end
end
```
Use `mocha` stubs only for third-party SDK/network boundaries — not for Train's
own classes, which should be driven through their real interfaces.

### Coverage & style gates
- **Coverage is not gated.** SimpleCov runs only when `CI_ENABLE_COVERAGE` is set
  and enforces no `minimum_coverage` (see "Coverage Configuration" above). >80% is
  a goal, not a build gate.
- Run **ChefStyle** before submitting: `chefstyle` (auto-fix with `chefstyle -a`).
  `chefstyle` is loaded in the `Rakefile` — this *is* an enforced style gate.
- Keep unit tests deterministic and offline; anything requiring sudo, SSH, WinRM,
  Docker, or a cloud/API credential belongs in the gated integration tasks.
