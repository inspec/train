resource "github_issue_label" "aspect_correctness" {
  repository  = "${var.repo_name}"
  name        = "Aspect/Correctness"
  color       = "d1232f" # crimson
  description = "Is it actually right?  Does it match a specification?"
}

resource "github_issue_label" "aspect_docs" {
  repository  = "${var.repo_name}"
  name        = "Aspect/Docs"
  color       = "65306b" # purple
  description = "Write the fine manual"
}

resource "github_issue_label" "aspect_integration" {
  repository  = "${var.repo_name}"
  name        = "Aspect/Integration"
  color       = "65306b" # purple
  description = "Works with other systems"
}

resource "github_issue_label" "aspect_packaging" {
  repository  = "${var.repo_name}"
  name        = "Aspect/Packaging"
  color       = "65306b" # purple
  description = "How the software is delivered"
}

resource "github_issue_label" "aspect_performance" {
  repository  = "${var.repo_name}"
  name        = "Aspect/Performance"
  color       = "65306b" # purple
  description = "Impact when ruunning"
}

resource "github_issue_label" "aspect_portability" {
  repository  = "${var.repo_name}"
  name        = "Aspect/Portability"
  color       = "65306b" # purple
  description = "Does it run on all targeted platforms?"
}

resource "github_issue_label" "aspect_security" {
  repository  = "${var.repo_name}"
  name        = "Aspect/Security"
  color       = "65306b" # purple
  description = "Is it safe?"
}

resource "github_issue_label" "aspect_stability" {
  repository  = "${var.repo_name}"
  name        = "Aspect/Stability"
  color       = "65306b" # purple
  description = "Same result, every time"
}

resource "github_issue_label" "aspect_testing" {
  repository  = "${var.repo_name}"
  name        = "Aspect/Testing"
  color       = "65306b" # purple
  description = "Did we check if it actually worked?"
}

resource "github_issue_label" "aspect_uiux" {
  repository  = "${var.repo_name}"
  name        = "Aspect/UI-UX"
  color       = "65306b" # purple
  description = "Any sharp edges?"
}
