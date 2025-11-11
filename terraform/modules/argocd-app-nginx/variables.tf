variable "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
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
  description = "Path to the application manifests in the repository"
  type        = string
}

variable "app_namespace" {
  description = "Namespace where the application will be deployed"
  type        = string
  default     = "demo"
}

variable "depends_upon" {
  description = "Dependencies for this module"
  type        = any
  default     = []
}

variable "github_token" {
  description = "GitHub personal access token for private repositories"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_username" {
  description = "GitHub username for private repositories"
  type        = string
  default     = ""
}