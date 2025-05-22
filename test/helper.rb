if ENV["CI_ENABLE_COVERAGE"]
  require "simplecov"
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
  ])

  SimpleCov.start do
    add_filter "/test/"
  end
end

require "minitest/autorun"
require "minitest/spec"
require "mocha/minitest"
require "train"

class Minitest::Spec
  before do
    Train::Platforms.__reset
    Train::Platforms::Detect::Specifications::OS.load
  end
end
