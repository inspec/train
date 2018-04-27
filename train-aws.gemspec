# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'train/version'

Gem::Specification.new do |spec|
  spec.name          = 'train-aws'
  spec.version       = Train::VERSION
  spec.authors       = ['Dominik Richter']
  spec.email         = ['dominik.richter@gmail.com']
  spec.summary       = 'Provides AWS support to train-core.'
  spec.description   = 'Provides AWS support to train-core.'
  spec.homepage      = 'https://github.com/chef/train/'
  spec.license       = 'Apache-2.0'

  spec.files = %w{train-aws.gemspec README.md LICENSE Gemfile CHANGELOG.md
                  lib/train/transports/aws.rb}

  spec.require_paths = ['lib']

  spec.add_dependency 'train-core'
  spec.add_dependency 'aws-sdk', '~> 2'
end
