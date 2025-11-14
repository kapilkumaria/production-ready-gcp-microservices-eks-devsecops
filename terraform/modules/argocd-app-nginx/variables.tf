variable "argocd_namespace" {
  description = "Namespace where ArgoCD itself is installed"
  type        = string
  default     = "argocd"
}

variable "repo_url" {
  description = "Git repository URL"
  type        = string
}

variable "target_revision" {
  description = "Git branch or tag to sync"
  type        = string
  default     = "main"
}

variable "app_path" {
  description = "Path to the NGINX manifests inside the repo"
  type        = string
}

variable "app_namespace" {
  description = "Namespace where the app will be deployed"
  type        = string
  default     = "nginx-app"
}

variable "depends_upon" {
  description = "Dependencies for sequencing"
  type        = any
  default     = []
}

variable "github_token" {
  description = "GitHub personal access token (if repo is private)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "github_username" {
  description = "GitHub username (if repo is private)"
  type        = string
  default     = ""
}

variable "name" {
  type    = string
  default = "nginx-app"
}
