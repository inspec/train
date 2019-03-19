resource "github_issue_label" "priority_low" {
  repository  = "${var.repo_name}"
  name        = "Priority/Low"
  color       = "3BB273"
  description = ""
}

resource "github_issue_label" "priority_medium" {
  repository  = "${var.repo_name}"
  name        = "Priority/Medium"
  color       = "E1BC29" # yellow
  description = ""
}

resource "github_issue_label" "priority_high" {
  repository  = "${var.repo_name}"
  name        = "Priority/High"
  color       = "d1232f" # crimson
  description = ""
}