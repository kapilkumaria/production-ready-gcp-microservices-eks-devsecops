data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module Call
module "vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
  vpc_cidr   = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
}

# IAM Module Call
module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
  cluster_name = var.cluster_name
}

# EKS Module Call
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

# Fetch cluster OIDC info
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

# IRSA Module Call
data "aws_caller_identity" "current" {}

module "irsa" {
  source = "./modules/irsa"

  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn       = module.eks.oidc_provider_arn
  account_id              = data.aws_caller_identity.current.account_id
}

# Monitoring Module Call
module "monitoring" {
  source = "./modules/monitoring"

  cluster_name = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data

  depends_on = [module.eks] # Ensure EKS is created before Helm chart deployment
}

# IRSA for cert-manager Module Call
module "irsa_cert_manager" {
  source = "./modules/irsa-cert-manager"

  cluster_name              = module.eks.cluster_name
  cluster_oidc_issuer_url  = module.eks.cluster_oidc_issuer_url
  domain                   = var.domain_name   # e.g. "kapilkumaria.com"
}

# Cert-Manager Module Call
module "cert_manager" {
  source       = "./modules/cert-manager"
  irsa_role_arn = module.irsa_cert_manager.cert_manager_irsa_role_arn  # <-- Uses output from IRSA module

  depends_on = [
    module.irsa_cert_manager,
    module.eks
  ]
}



