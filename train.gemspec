lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "train/version"

Gem::Specification.new do |spec|
  spec.name          = "train"
  spec.version       = Train::VERSION
  spec.authors       = ["Chef InSpec Team"]
  spec.email         = ["inspec@chef.io"]
  spec.summary       = "Transport interface to talk to different backends."
  spec.description   = "Transport interface to talk to different backends."
  spec.license       = "Apache-2.0"

  spec.metadata = {
    "homepage_uri" => "https://github.com/inspec/train",
    "changelog_uri" => "https://github.com/inspec/train/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/inspec/train",
    "bug_tracker_uri" => "https://github.com/inspec/train/issues",
  }

  spec.required_ruby_version = ">= 2.7"

  spec.files = %w{LICENSE} + Dir.glob("lib/**/*")
    .grep(%r{transports/(azure|clients|docker|podman|gcp|helpers|vmware)})
    .reject { |f| File.directory?(f) }

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "train-core", "= #{Train::VERSION}"
  spec.add_dependency "train-winrm", "~> 0.2"

  # azure, docker, gcp dependencies
  spec.add_dependency "activesupport", ">= 6.0.3.1"
  spec.add_dependency "inifile", "~> 3.0"
  spec.add_dependency "azure_graph_rbac", "~> 0.16"
  spec.add_dependency "azure_mgmt_key_vault", "~> 0.17"
  spec.add_dependency "azure_mgmt_resources", "~> 0.15"
  spec.add_dependency "azure_mgmt_security", "~> 0.18"
  spec.add_dependency "azure_mgmt_storage", "~> 0.18"
  spec.add_dependency "docker-api", ">= 1.26", "< 3.0"
  spec.add_dependency "googleauth"
  spec.add_dependency "google-apis-admin_directory_v1"
  spec.add_dependency "google-apis-container_v1beta1","~> 0.61.0"
  spec.add_dependency "google-apis-container_v1"
  spec.add_dependency "google-apis-cloudkms_v1"
  spec.add_dependency "google-apis-logging_v2"
  spec.add_dependency "google-apis-monitoring_v3"
  spec.add_dependency "google-apis-sqladmin_v1beta4"
  spec.add_dependency "google-apis-dns_v1beta2"
  spec.add_dependency "google-apis-compute_v1"
  spec.add_dependency "google-apis-cloudresourcemanager_v1"
  spec.add_dependency "google-apis-storage_v1"
  spec.add_dependency "google-apis-iam_v1"
end
