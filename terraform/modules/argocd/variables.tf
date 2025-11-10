variable "namespace" {
  description = "Namespace where Argo CD will be installed"
  type        = string
  default     = "argocd"
}

variable "domain" {
  description = "Base domain, e.g., kapilkumaria.com"
  type        = string
}

variable "cluster_issuer_name" {
  description = "ClusterIssuer to use (currently staging in your setup)"
  type        = string
  default     = "letsencrypt-production"
}

variable "certificate_secret_name" {
  description = "TLS secret name for the wildcard cert in the Argo CD namespace"
  type        = string
  default     = "wildcard-kapilkumaria-com-tls"
}

variable "helm_chart_version" {
  description = "Argo CD Helm chart version (keep reasonably current)"
  type        = string
  # Pin to a recent stable; bump later as you like
  default     = "6.9.3"
}
