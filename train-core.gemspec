# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'train/version'

Gem::Specification.new do |spec|
  spec.name          = 'train-core'
  spec.version       = Train::VERSION
  spec.authors       = ['Dominik Richter']
  spec.email         = ['dominik.richter@gmail.com']
  spec.summary       = 'Transport interface to talk to a selected set of backends.'
  spec.description   = 'A minimal Train with a selected set of backends, ssh, winrm, and docker.'
  spec.homepage      = 'https://github.com/chef/train/'
  spec.license       = 'Apache-2.0'

  spec.files = %w{train-core.gemspec README.md LICENSE Gemfile CHANGELOG.md} +
    Dir.glob('{lib,test}/**/*', File::FNM_DOTMATCH)
    .reject { |f| File.directory?(f) || f =~ /aws|azure|gcp/ }

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'json', '>= 1.8', '< 3.0'
  # chef-client < 12.4.1 require mixlib-shellout-2.0.1
  spec.add_dependency 'mixlib-shellout', '~> 2.0'
  # net-ssh 3.x drops Ruby 1.9 support, so this constraint could be raised when
  # 1.9 support is no longer needed here or for Inspec
  spec.add_dependency 'net-ssh', '>= 2.9', '< 5.0'
  spec.add_dependency 'net-scp', '~> 1.2'
  spec.add_dependency 'winrm', '~> 2.0'
  spec.add_dependency 'winrm-fs', '~> 1.0'
  spec.add_dependency 'docker-api', '~> 1.26'
  spec.add_dependency 'inifile'
end
