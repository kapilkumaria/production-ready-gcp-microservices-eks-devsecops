output "irsa_role_arn" {
  description = "IAM Role ARN for base IRSA role"
  value       = module.irsa_role.iam_role_arn
}

