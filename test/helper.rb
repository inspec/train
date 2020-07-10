if ENV["CI_ENABLE_COVERAGE"]
  require "simplecov"
  require "coveralls"
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter,
  ])

  SimpleCov.start do
    add_filter "/test/"
  end
end

require "minitest/autorun"
require "minitest/spec"
require "mocha/minitest"
require "byebug"

require "train"

class Minitest::Spec
  before do
    Train::Platforms.__reset
    Train::Platforms::Detect::Specifications::OS.load
  end
end
