variable "project_name" {
  description = "Name prefix to use for IAM resources"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name to attach IAM roles and OIDC provider"
  type        = string
}
