# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'train/version'

CORE_TRANSPORTS = [
  'lib/train/transports/local.rb',
  'lib/train/transports/mock.rb',
  'lib/train/transports/ssh.rb',
  'lib/train/transports/ssh_connection.rb',
  'lib/train/transports/winrm.rb',
  'lib/train/transports/winrm_connection.rb',
].freeze

Gem::Specification.new do |spec|
  spec.name          = 'train-core'
  spec.version       = Train::VERSION
  spec.authors       = ['Dominik Richter']
  spec.email         = ['drichter@chef.io']
  spec.summary       = 'Transport interface to talk to a selected set of backends.'
  spec.description   = 'A minimal Train with a backends for ssh and winrm.'
  spec.homepage      = 'https://github.com/inspec/train/'
  spec.license       = 'Apache-2.0'

  spec.files = %w{LICENSE} + Dir
               .glob('lib/**/*', File::FNM_DOTMATCH)
               .reject { |f| f =~ %r{lib/train/transports} unless CORE_TRANSPORTS.include?(f) }
               .reject { |f| File.directory?(f) }

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'json', '>= 1.8', '< 3.0'
  spec.add_dependency 'mixlib-shellout', '>= 2.0', '< 4.0'
  spec.add_dependency 'net-ssh', '>= 2.9', '< 6.0'
  spec.add_dependency 'net-scp', '>= 1.2', '< 3.0'
  spec.add_dependency 'winrm', '~> 2.0'
  spec.add_dependency 'winrm-fs', '~> 1.0'
end
