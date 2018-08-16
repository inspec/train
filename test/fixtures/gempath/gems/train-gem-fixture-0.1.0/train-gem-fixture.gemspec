
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "train-gem-fixture"
  spec.version       = '0.1.0'
  spec.authors       = ["Inspec core engineering team"]
  spec.email         = ["hello@chef.io"]

  spec.summary       = %q{Test train plugin, packaged as a local gem}
  spec.description   = %q{Test train plugin, packaged as a local gem}
  spec.homepage      = "https://github.com/inspec/train"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = %w{
    README.md
    lib/train-gem-fixture.rb
    lib/train-gem-fixture/version.rb
    lib/train-gem-fixture/transport.rb
  }
  spec.executables   = []
  spec.require_paths = ["lib"]

  # No deps
end
