# encoding: utf-8
require "coveralls"
Coveralls.wear!

require "minitest/autorun"
require "minitest/spec"
require "mocha/minitest"
require "mocha/setup"
require "byebug"

require 'train'

# needed to force unix? and others to be created
Train::Platforms::Detect::Specifications::OS.load
