# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'train/version'

Gem::Specification.new do |spec|
  spec.name          = 'train'
  spec.version       = Train::VERSION
  spec.authors       = ['Dominik Richter']
  spec.email         = ['dominik.richter@gmail.com']
  spec.summary       = 'Transport interface to talk to different backends.'
  spec.description   = 'Transport interface to talk to different backends.'
  spec.homepage      = 'https://github.com/chef/train/'
  spec.license       = 'Apache-2.0'

  spec.files = %w{
    train.gemspec README.md Rakefile LICENSE Gemfile CHANGELOG.md .rubocop.yml
  } + Dir.glob(
    '{lib,test}/**/*', File::FNM_DOTMATCH
  ).reject { |f| File.directory?(f) }

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
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

  spec.add_development_dependency 'mocha', '~> 1.1'
end
