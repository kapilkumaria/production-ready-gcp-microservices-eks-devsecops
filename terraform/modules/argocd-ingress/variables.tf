variable "namespace" {
  type        = string
  description = "Namespace where ArgoCD is installed"
  default     = "argocd"
}

variable "domain" {
  type        = string
  description = "Base domain for ingress"
}

variable "depends_upon" {
  description = "Optional dependency hook for sequencing"
  default     = []
}
