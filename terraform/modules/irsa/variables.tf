variable "cluster_name" {
  type        = string
  description = "EKS Cluster name"
}

variable "oidc_provider_arn" {
  type        = string
  description = "OIDC Provider ARN from EKS module"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "cluster_oidc_issuer_url" {
  type = string
}
