variable "irsa_role_arn" {
  description = "IAM Role ARN for cert-manager (IRSA)"
  type        = string
}

variable "namespace" {
  description = "Namespace for cert-manager"
  type        = string
  default     = "cert-manager"
}
