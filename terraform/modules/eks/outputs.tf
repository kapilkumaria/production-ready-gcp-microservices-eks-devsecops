output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate data required for cluster auth"
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA (use to create IAM OIDC provider)"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "node_group_name" {
  description = "Managed node group name"
  value       = aws_eks_node_group.default.node_group_name
}
