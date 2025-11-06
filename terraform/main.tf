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

module "eks" {
  source = "./modules/eks"
  aws_region = var.aws_region

  project_name   = var.project_name
  environment    = var.environment

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  cluster_role_arn   = module.iam.eks_cluster_role_arn
  node_role_arn      = module.iam.eks_node_role_arn
  subnet_ids         = module.vpc.private_subnet_ids

  # Endpoint access strategy
  endpoint_public_access  = true
  endpoint_private_access = false

  # Node group config
  instance_types = ["t3.medium"]
  disk_size      = 20
  desired_size   = 2
  min_size       = 2
  max_size       = 4

  tags = {
    Owner = "kapil"
  }
}
