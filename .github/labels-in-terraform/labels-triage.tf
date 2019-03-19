resource "github_issue_label" "triage_duplicate" {
  repository  = "${var.repo_name}"
  name        = "Triage/Duplicate"
  color       = "f5c969" # butter yellow
  description = "See other issue"
}

resource "github_issue_label" "triage_support" {
  repository  = "${var.repo_name}"
  name        = "Triage/Support"
  color       = "f5c969" # butter yellow
  description = "A question, better answered elsewhere"
}

resource "github_issue_label" "triage_feature_request" {
  repository  = "${var.repo_name}"
  name        = "Triage/Feature Request"
  color       = "f5c969" # butter yellow
  description = "A request for new functionality"
}

resource "github_issue_label" "triage_needs_info" {
  repository  = "${var.repo_name}"
  name        = "Triage/Info Needed"
  color       = "f5c969" # butter yellow
  description = "More info needed in order to progress"
}

resource "github_issue_label" "triage_needs_spike" {
  repository  = "${var.repo_name}"
  name        = "Triage/Spike Needed"
  color       = "f5c969" # butter yellow
  description = "How big is it?"
}

resource "github_issue_label" "triage_declined" {
  repository  = "${var.repo_name}"
  name        = "Triage/Declined"
  color       = "f5c969" # butter yellow
  description = "Cannot or will not be resolved"
}

resource "github_issue_label" "triage_needs_adoption" {
  repository  = "${var.repo_name}"
  name        = "Triage/Needs Adoption"
  color       = "f5c969" # butter yellow
  description = "Needs to be handed off to make progress"
}