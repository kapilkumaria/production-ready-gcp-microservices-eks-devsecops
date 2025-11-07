variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

# OIDC values needed for IRSA
variable "oidc_provider_arn" {
  type        = string
  description = "IAM OIDC provider ARN for the EKS cluster"
}

variable "oidc_provider_url" {
  type        = string
  description = "OIDC issuer URL without https:// (e.g. oidc.eks.us-east-1.amazonaws.com/id/XXXX)"
}

variable "namespace" {
  type        = string
  default     = "kube-system"
}

