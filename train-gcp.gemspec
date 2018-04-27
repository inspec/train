# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'train/version'

Gem::Specification.new do |spec|
  spec.name          = 'train-gcp'
  spec.version       = Train::VERSION
  spec.authors       = ['Dominik Richter']
  spec.email         = ['dominik.richter@gmail.com']
  spec.summary       = 'Provides Google Cloud Provider support to train-core.'
  spec.description   = 'Provides Google Cloud Provider support to train-core.'
  spec.homepage      = 'https://github.com/chef/train/'
  spec.license       = 'Apache-2.0'

  spec.files = %w{train-gcp.gemspec README.md LICENSE CHANGELOG.md
                  lib/train/transports/gcp.rb}

  spec.require_paths = ['lib']

  spec.add_dependency 'train-core'
  spec.add_dependency 'google-api-client', '~> 0.19.8'
  spec.add_dependency 'googleauth', '~> 0.6.2'
  spec.add_dependency 'google-cloud', '~> 0.51.1'
  spec.add_dependency 'google-protobuf', '= 3.5.1'
end
