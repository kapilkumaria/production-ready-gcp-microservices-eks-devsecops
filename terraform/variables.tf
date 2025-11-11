variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_region" {}
variable "project_name" {}
variable "cluster_name" {}
variable "cluster_version" {}

variable "domain_name" {
  type        = string
  description = "Base domain for Route53, e.g. kapilkumaria.com"
}

# variable "domain_name" { type = string }
variable "nlb_hosted_zone_id" {
  type    = string
  default = "" # fill after fetching via AWS CLI
}
