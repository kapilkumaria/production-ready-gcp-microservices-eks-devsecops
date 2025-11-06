data "aws_availability_zones" "available" {
  state = "available"
}

variable "aws_region" {}




module "vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
  vpc_cidr   = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
}