variable "github_organization" {
  default = "inspec"
  type = "string"
}

variable "repo_name" {
  default = "train"
  type = "string"
}

variable "github_token" {
  # You can set env var TF_VAR_github_token to set this
  type = "string"
}