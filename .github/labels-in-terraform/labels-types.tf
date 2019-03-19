resource "github_issue_label" "type_bug" {
  repository  = "${var.repo_name}"
  name        = "Type/Bug"
  color       = "d1232f" # crimson
  description = "It doesn't work as expected"
}

resource "github_issue_label" "type_chore" {
  repository  = "${var.repo_name}"
  name        = "Type/Chore"
  color       = "2727cc" # cobalt blue
  description = "Non-critical maintenance"
}

resource "github_issue_label" "type_spike" {
  repository  = "${var.repo_name}"
  name        = "Type/Spike"
  color       = "2727cc" # cobalt blue
  description = "Clarify an estimate"
}
resource "github_issue_label" "type_enhancement" {
  repository  = "${var.repo_name}"
  name        = "Type/Enhancement"
  color       = "2727cc" # cobalt blue
  description = "Improves an existing feature"
}

resource "github_issue_label" "type_deprecation" {
  repository  = "${var.repo_name}"
  name        = "Type/Deprecation"
  color       = "2727cc" # cobalt blue
  description = "Removes or changes an existing feature"
}

resource "github_issue_label" "type_new_feature" {
  repository  = "${var.repo_name}"
  name        = "Type/New Feature"
  color       = "2727cc" # cobalt blue
  description = "Adds new functionality"
}

resource "github_issue_label" "type_rfc" {
  repository  = "${var.repo_name}"
  name        = "Type/RFC"
  color       = "2727cc" # cobalt blue
  description = "Community discussion"
}

resource "github_issue_label" "type_tech_debt" {
  repository  = "${var.repo_name}"
  name        = "Type/Tech Debt"
  color       = "2727cc" # cobalt blue
  description = "Internal refactoring"
}