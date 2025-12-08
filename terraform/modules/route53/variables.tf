variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID for kapilkumaria.com"
  type        = string
}

variable "domain" {
  description = "Base domain, e.g., kapilkumaria.com"
  type        = string
}

variable "create_apex_alias" {
  description = "Whether to create A ALIAS for apex (requires nlb_hosted_zone_id)"
  type        = bool
  default     = true
}

variable "nlb_hosted_zone_id" {
  description = "HostedZoneId of the NLB backing the ingress controller (from AWS ELBv2). If blank, apex A record is skipped."
  type        = string
  default     = ""
}

# Namespace where ingress-nginx runs
variable "ingress_namespace" {
  type        = string
  default     = "ingress-nginx"
}

# Name of the ingress-nginx Service (type=LoadBalancer)
variable "ingress_service_name" {
  type        = string
  default     = "ingress-nginx-controller"
}

variable "nlb_dns_name" {
  type = string
}

variable "additional_records" {
  type = map(object({
    name = string
  }))
  default = {}
}
