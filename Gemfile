# encoding: utf-8
source 'https://rubygems.org'
gemspec name: 'train'

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.2.2')
  gem 'json', '< 2.0'
end

# bundler is built into Ruby 2.6 and later
if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.6')
  gem 'bundler', '~> 1.11'
end

group :test do
  gem 'minitest', '~> 5.8'
  gem 'rake', '~> 12'
  gem 'rubocop', '~> 0.36.0'
  gem 'simplecov', '~> 0.10'
  gem 'concurrent-ruby', '~> 1.0'
  gem 'pry-byebug'
  gem 'm'
  # This is not a true gem installation
  # (Gem::Specification.find_by_path('train-gem-fixture') will return nil)
  # but it's close enough to show the gempath handler can find a plugin
  # See test/unit/
  gem 'train-test-fixture', path: 'test/fixtures/plugins/train-test-fixture'
end

group :integration do
  gem 'berkshelf', '~> 5.2'
  gem 'test-kitchen', '~> 1.11'
  gem 'kitchen-vagrant'
end

group :tools do
  gem 'pry', '~> 0.10'
  gem 'rb-readline'
  gem 'license_finder'
end
