source "https://rubygems.org"
gemspec name: "train"

if Gem.ruby_version.to_s.start_with?("2.5")
  # 16.7.23 required ruby 2.6+
  gem "chef-utils", "< 16.7.23" # TODO: remove when we drop ruby 2.5
end

group :test do
  gem "coveralls", require: false
  gem "minitest", "~> 5.8"
  gem "rake", "~> 13.0"
  gem "chefstyle", "2.1.1"
  gem "concurrent-ruby", "~> 1.0"
  gem "pry-byebug"
  gem "m"
  gem "ed25519" # ed25519 ssh key support
  gem "bcrypt_pbkdf" # ed25519 ssh key support
  # This is not a true gem installation
  # (Gem::Specification.find_by_path('train-gem-fixture') will return nil)
  # but it's close enough to show the gempath handler can find a plugin
  # See test/unit/
  gem "train-test-fixture", path: "test/fixtures/plugins/train-test-fixture"
  gem "mocha", "~> 2.1"
end

if Gem.ruby_version >= Gem::Version.new("2.7.0")
  group :integration do
    gem "berkshelf", ">= 6.0"
    gem "test-kitchen", ">= 2"
    gem "kitchen-vagrant"
  end
end

group :tools do
  gem "pry", "~> 0.10"
  gem "rb-readline"
  gem "license_finder"
end
