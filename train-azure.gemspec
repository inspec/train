# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'train/version'

Gem::Specification.new do |spec|
  spec.name          = 'train-azure'
  spec.version       = Train::VERSION
  spec.authors       = ['Dominik Richter']
  spec.email         = ['dominik.richter@gmail.com']
  spec.summary       = 'Provides Azure support to train-core.'
  spec.description   = 'Provides Azure support to train-core.'
  spec.homepage      = 'https://github.com/chef/train/'
  spec.license       = 'Apache-2.0'

  spec.files = %w{train-azure.gemspec README.md LICENSE CHANGELOG.md
                  lib/train/transports/azure.rb}

  spec.require_paths = ['lib']

  spec.add_dependency 'train-core'
  spec.add_dependency 'azure_mgmt_resources', '~> 0.15'
end
