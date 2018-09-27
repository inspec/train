# This is a unit test for the example Train plugin, LocalRot13.
# Its job is to verify that the Transport class is setup correctly.

# Include our test harness
require_relative '../helper'

# Load the class under test, the Plugin definition.
require 'train-local-rot13/transport'

# Because InSpec is a Spec-style test suite, we're going to use MiniTest::Spec
# here, for familiar look and feel. However, this isn't InSpec (or RSpec) code.
describe TrainPlugins::LocalRot13::Transport do

  # When writing tests, you can use `let` to create variables that you
  # can reference easily.

  # This is a long name.  Shorten it for clarity.
  let(:plugin_class) { TrainPlugins::LocalRot13::Transport }

  # Some tests through here use minitest Expectations, which attach to all
  # Objects, and begin with 'must' (positive) or 'wont' (negative)
  # See https://ruby-doc.org/stdlib-2.1.0/libdoc/minitest/rdoc/MiniTest/Expectations.html

  it "should be registered with the plugin registry without the train- prtefix" do
    # Note that Train uses String keys here, not Symbols
    Train::Plugins.registry.keys.wont_include('train-local-rot13')
    Train::Plugins.registry.keys.must_include('local-rot13')
  end

  it "should inherit from the Train plugin base" do
    # For Class, '<' means 'is a descendant of'
    (plugin_class < Train.plugin(1)).must_equal(true)
  end

  it "should provide a connection() method" do
    # false passed to instance_methods says 'don't use inheritance'
    plugin_class.instance_methods(false).must_include(:connection)
  end
end
