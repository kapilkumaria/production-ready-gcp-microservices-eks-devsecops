variable "email" {
  description = "Email for Let's Encrypt registration"
  type        = string
}

variable "domain" {
  description = "Root domain name (e.g., kapilkumaria.com)"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 zone ID for DNS-01 challenge"
  type        = string
}

variable "cert_manager_service_account" {
  description = "ServiceAccount used by cert-manager"
  type        = string
  default     = "cert-manager"
}

variable "namespace" {
  description = "Namespace where cert-manager is installed"
  type        = string
  default     = "cert-manager"
}

variable "irsa_role_arn" {
  description = "IAM Role ARN for cert-manager IRSA"
  type        = string
}
