# VPC Outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnet_ids
}

output "private_subnets" {
  value = module.vpc.private_subnet_ids
}

# EKS Outputs
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

# # IAM Outputs
# output "eks_cluster_role" {
#   value = module.iam.cluster_role_arn
# }

# output "eks_node_role" {
#   value = module.iam.node_role_arn
# }

# IRSA Outputs
output "irsa_role_arn" {
  value = module.irsa.irsa_role_arn
}

output "cert_manager_irsa_role_arn" {
  value = module.irsa_cert_manager.role_arn
}

output "cert_manager_route53_zone_id" {
  value = module.irsa_cert_manager.zone_id
}
