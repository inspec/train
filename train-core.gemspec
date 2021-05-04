lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "train/version"

Gem::Specification.new do |spec|
  spec.name          = "train-core"
  spec.version       = Train::VERSION
  spec.authors       = ["Chef InSpec Team"]
  spec.email         = ["inspec@chef.io"]
  spec.summary       = "Transport interface to talk to a selected set of backends."
  spec.description   = "A minimal Train with a backends for ssh and winrm."
  spec.license       = "Apache-2.0"

  spec.metadata = {
    "homepage_uri" => "https://github.com/inspec/train",
    "changelog_uri" => "https://github.com/inspec/train/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/inspec/train",
    "bug_tracker_uri" => "https://github.com/inspec/train/issues",
  }

  spec.required_ruby_version = ">= 2.5"

  spec.files = Dir.glob("{LICENSE,lib/**/*}")
    .grep_v(%r{transports/(azure|clients|docker|gcp|helpers|vmware)})
    .reject { |f| File.directory?(f) }

  spec.require_paths = ["lib"]

  spec.add_dependency "addressable", "~> 2.5"
  spec.add_dependency "ffi", "!= 1.13.0" # train-core doesn't directly depend on FFI, but 1.13.0 broke windows
  spec.add_dependency "json", ">= 1.8", "< 3.0"
  spec.add_dependency "mixlib-shellout", ">= 2.0", "< 4.0"
  spec.add_dependency "net-scp", ">= 1.2", "< 4.0"
  spec.add_dependency "net-ssh", ">= 2.9", "< 7.0"
end
