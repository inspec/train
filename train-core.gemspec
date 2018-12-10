# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'train/version'

CORE_TRANSPORTS = [
  'lib/train/transports/local.rb',
  'lib/train/transports/mock.rb',
].freeze

Gem::Specification.new do |spec|
  spec.name          = 'train-core'
  spec.version       = Train::VERSION
  spec.authors       = ['Dominik Richter']
  spec.email         = ['drichter@chef.io']
  spec.summary       = 'Transport interface to talk to a selected set of backends.'
  spec.description   = 'A minimal Train with a selected set of backends, ssh, winrm, and docker.'
  spec.homepage      = 'https://github.com/inspec/train/'
  spec.license       = 'Apache-2.0'

  spec.files = %w{LICENSE} + Dir
               .glob('lib/**/*', File::FNM_DOTMATCH)
               .reject { |f| f =~ %r{lib/train/transports} unless CORE_TRANSPORTS.include?(f) }
               .reject { |f| File.directory?(f) }

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # chef-client < 12.4.1 require mixlib-shellout-2.0.1
  spec.add_dependency 'mixlib-shellout', '~> 2.0'
  spec.add_dependency 'json', '>= 1.8', '< 3.0'
end
