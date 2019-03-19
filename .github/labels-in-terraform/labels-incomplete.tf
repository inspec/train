resource "github_issue_label" "incomplete_merge_conflict" {
  repository  = "${var.repo_name}"
  name        = "Incomplete/Merge Conflict"
  color       = "b7fc71" # Lime
  description = "Please fix the conflicts"
}

resource "github_issue_label" "incomplete_linting" {
  repository  = "${var.repo_name}"
  name        = "Incomplete/Linting"
  color       = "b7fc71" # Lime
  description = "Failed the stylechecker."
}

resource "github_issue_label" "incomplete_needs_tests" {
  repository  = "${var.repo_name}"
  name        = "Incomplete/Tests Needed"
  color       = "b7fc71" # Lime
  description = "How do we know it works?"
}
resource "github_issue_label" "incomplete_needs_docs" {
  repository  = "${var.repo_name}"
  name        = "Incomplete/Docs Needed"
  color       = "b7fc71" # Lime
  description = "Write The Fine Manual"
}
resource "github_issue_label" "incomplete_implementation" {
  repository  = "${var.repo_name}"
  name        = "Incomplete/Implementation"
  color       = "b7fc71" # Lime
  description = "See comments, code-level issue"
}
resource "github_issue_label" "incomplete_approach" {
  repository  = "${var.repo_name}"
  name        = "Incomplete/Approach"
  color       = "b7fc71" # Lime
  description = "See comments, design-level issue"
}