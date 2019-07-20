# encoding: utf-8
require "coveralls"
Coveralls.wear!

require "minitest/autorun"
require "minitest/spec"
require "mocha/minitest"
require "mocha/setup"
require "byebug"

require "train"

class Minitest::Spec
  before do
    Train::Platforms.__reset
    Train::Platforms::Detect::Specifications::OS.load
  end
end
