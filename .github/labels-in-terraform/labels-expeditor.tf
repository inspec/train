resource "github_issue_label" "expeditor_skip_all" {
  repository  = "${var.repo_name}"
  name        = "Expeditor/Skip All"
  color       = "cccccc" # light grey
  description = "CI/CD: Don't do anything on merge"
}

resource "github_issue_label" "expeditor_skip_changelog" {
  repository  = "${var.repo_name}"
  name        = "Expeditor/Skip Changelog"
  color       = "cccccc" # light grey
  description = "CI/CD: Don't update the changelog on merge"
}

resource "github_issue_label" "expeditor_skip_version_bump" {
  repository  = "${var.repo_name}"
  name        = "Expeditor/Skip Version Bump"
  color       = "cccccc" # light grey
  description = "CI/CD: Don't bump the version"
}

resource "github_issue_label" "expeditor_bump_major_version" {
  repository  = "${var.repo_name}"
  name        = "Expeditor/Bump Major Version"
  color       = "d1232f" # crimson
  description = "CI/CD: Increase the major version, reset minor and patch"
}

resource "github_issue_label" "expeditor_bump_minor_version" {
  repository  = "${var.repo_name}"
  name        = "Expeditor/Bump Minor Version"
  color       = "cccccc" # light grey
  description = "CI/CD: Increase the minor version, reset patch"
}
