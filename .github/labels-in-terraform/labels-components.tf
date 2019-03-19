# This file is custom to the train project

#-------------------------------------------------------------#
#                      Components
#-------------------------------------------------------------#

resource "github_issue_label" "component_platform_detection" {
  repository  = "${var.repo_name}"
  name        = "Component/Platform Detection"
  color       = "48bdb9" # aqua
  description = "Identification of the target"
}

resource "github_issue_label" "component_connection_api" {
  repository  = "${var.repo_name}"
  name        = "Component/Connection API"
  color       = "48bdb9" # aqua
  description = "Cmmon things connections do"
}

resource "github_issue_label" "component_options" {
  repository  = "${var.repo_name}"
  name        = "Component/Option Handling"
  color       = "48bdb9" # aqua
  description = "Options and Credentials"
}

resource "github_issue_label" "component_fs_access" {
  repository  = "${var.repo_name}"
  name        = "Component/FS Access"
  color       = "48bdb9" # aqua
  description = "Reading files from the filesystem"
}
resource "github_issue_label" "component_logging" {
  repository  = "${var.repo_name}"
  name        = "Component/Logging"
  color       = "48bdb9" # aqua
  description = "When and what we log"
}

resource "github_issue_label" "component_plugin_api" {
  repository  = "${var.repo_name}"
  name        = "Component/Plugin API"
  color       = "48bdb9" # aqua
  description = "How train plugins talk to train"
}
resource "github_issue_label" "component_uuid" {
  repository  = "${var.repo_name}"
  name        = "Component/UUID Generation"
  color       = "48bdb9" # aqua
  description = "Generating unique IDs"
}

#-------------------------------------------------------------#
#                      Transports
#-------------------------------------------------------------#

resource "github_issue_label" "transport_aws" {
  repository  = "${var.repo_name}"
  name        = "Transport/AWS"
  color       = "eb6420" # orange
  description = ""
}
resource "github_issue_label" "transport_azure" {
  repository  = "${var.repo_name}"
  name        = "Transport/Azure"
  color       = "eb6420" # orange
  description = ""
}
resource "github_issue_label" "transport_cisco" {
  repository  = "${var.repo_name}"
  name        = "Transport/Cisco"
  color       = "eb6420" # orange
  description = ""
}
resource "github_issue_label" "transport_docker" {
  repository  = "${var.repo_name}"
  name        = "Transport/Docker"
  color       = "eb6420" # orange
  description = ""
}

resource "github_issue_label" "transport_gcp" {
  repository  = "${var.repo_name}"
  name        = "Transport/GCP"
  color       = "eb6420" # orange
  description = ""
}

resource "github_issue_label" "transport_local" {
  repository  = "${var.repo_name}"
  name        = "Transport/Local"
  color       = "eb6420" # orange
  description = ""
}
resource "github_issue_label" "transport_ssh" {
  repository  = "${var.repo_name}"
  name        = "Transport/SSH"
  color       = "eb6420" # orange
  description = ""
}
resource "github_issue_label" "transport_winrm" {
  repository  = "${var.repo_name}"
  name        = "Transport/WinRM"
  color       = "eb6420" # orange
  description = ""
}