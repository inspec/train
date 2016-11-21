# encoding: utf-8
source 'https://rubygems.org'
gemspec

# pin dependency for Ruby 1.9.3 since bundler is not
# detecting that net-ssh 3 does not work with 1.9.3
if Gem::Version.new(RUBY_VERSION) <= Gem::Version.new('1.9.3')
  gem 'net-ssh', '~> 2.9'
end

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.2.2')
  gem 'json', '< 2.0'
  gem 'rack', '< 2.0'
end

group :test do
  gem 'bundler', '~> 1.11'
  gem 'minitest', '~> 5.8'
  gem 'rake', '~> 10'
  gem 'rubocop', '~> 0.36.0'
  gem 'simplecov', '~> 0.10'
  gem 'concurrent-ruby', '~> 0.9'
end

group :integration do
  gem 'berkshelf', '~> 4.3'
  gem 'test-kitchen', '~> 1.11'
  gem 'kitchen-vagrant'
end

group :tools do
  gem 'pry', '~> 0.10'
  gem 'rb-readline'
  gem 'license_finder'
  gem 'github_changelog_generator', '~> 1'
end
