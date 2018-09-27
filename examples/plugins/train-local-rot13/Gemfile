# encoding: utf-8
source 'https://rubygems.org'

# This is Gemfile, which is used by bundler
# to ensure a coherent set of gems is installed.
# This file lists dependencies needed when outside
# of a gem (the gemspec lists deps for gem deployment)

# Bundler should refer to the gemspec for any dependencies.
gemspec

# Remaining group is only used for development.
group :development do
  gem 'bundler'
  gem 'byebug'
  gem 'inspec', '>= 2.2.112' # We need InSpec for the test harness while developing.
  gem 'minitest'
  gem 'rake'
  gem 'rubocop', '= 0.49.1' # Need to keep in sync with main InSpec project, so config files will work
end
