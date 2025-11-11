# ----------------- Variables -----------------
variable "argocd_namespace" {
  description = "Namespace where Argo CD is installed"
  type        = string
  default     = "argocd"
}

variable "repo_url" {
  description = "Git repository URL containing the nginx app manifests"
  type        = string
}

variable "target_revision" {
  description = "Branch or tag in the repo"
  type        = string
  default     = "main"
}

variable "app_path" {
  description = "Path inside repo containing manifests (e.g. manifests/nginx-app)"
  type        = string
}

variable "app_namespace" {
  description = "Kubernetes namespace for the nginx app"
  type        = string
  default     = "demo"
}

variable "depends_upon" {
  description = "Optional dependency for sequencing"
  default     = []
}

output "nginx_app_name" {
  value = "nginx-sample"
}