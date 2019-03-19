resource "github_issue_label" "platform_mac_os" {
  repository  = "${var.repo_name}"
  name        = "Platform/MacOS"
  color       = "759442" # sage
  description = ""
}

resource "github_issue_label" "platform_windows" {
  repository  = "${var.repo_name}"
  name        = "Platform/Windows"
  color       = "759442" # sage
  description = ""
}

resource "github_issue_label" "platform_unix_like" {
  repository  = "${var.repo_name}"
  name        = "Platform/UNIX-Like"
  color       = "759442" # sage
  description = ""
}
