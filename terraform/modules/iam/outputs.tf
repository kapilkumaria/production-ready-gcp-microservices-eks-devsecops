output "eks_cluster_role_arn" {
  description = "IAM Role ARN for EKS Control Plane"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  description = "IAM Role ARN for EKS Worker Nodes"
  value       = aws_iam_role.eks_node_role.arn
}

# output "oidc_provider_arn" {
#   description = "IAM OIDC Provider ARN for IRSA"
#   value       = aws_iam_openid_connect_provider.oidc.arn
# }
