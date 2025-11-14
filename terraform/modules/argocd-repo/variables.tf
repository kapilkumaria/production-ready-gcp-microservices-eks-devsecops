variable "repo_url" {
  type = string
}

variable "github_username" {
  type      = string
  sensitive = true
}

variable "github_token" {
  type      = string
  sensitive = true
}
