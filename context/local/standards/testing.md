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