data "aws_availability_zones" "available" {
  state = "available"
}

# variable "aws_region" {}

module "vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
  vpc_cidr   = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
  cluster_name = var.cluster_name
}
