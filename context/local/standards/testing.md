### Testing Standards

#### Unit Testing Requirements
- **Framework**: Minitest (primary testing framework)
- **Coverage**: Maintain > 80% test coverage
- **Location**: Tests should be in `test/unit/` directories
- **Naming**: Test files should end with `_test.rb`
- **Mocking**: Use `mocha/minitest` for mocking external dependencies

#### Coverage Configuration
```ruby
# Example SimpleCov configuration
SimpleCov.start do
  add_filter "/test/"
  add_group "Transports", ["lib/train/transports"]
  add_group "Platforms", ["lib/train/platforms"]
  add_group "Plugins", ["lib/train/plugins"]
  minimum_coverage 80
end
```

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
- Maintain **> 80%** coverage (SimpleCov, configured in `test/helper.rb`).
- Run **ChefStyle** before submitting: `chefstyle` (auto-fix with `chefstyle -a`).
  `chefstyle` is loaded in the `Rakefile`.
- Keep unit tests deterministic and offline; anything requiring sudo, SSH, WinRM,
  Docker, or a cloud/API credential belongs in the gated integration tasks.
