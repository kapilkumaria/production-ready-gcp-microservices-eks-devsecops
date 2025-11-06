# IRSA role for cert-manager to solve DNS-01 via Route53
data "aws_route53_zone" "this" {
  name         = var.domain
  private_zone = false
}

resource "aws_iam_policy" "certmanager_route53" {
  name        = "${var.cluster_name}-certmanager-route53"
  description = "Allow cert-manager to manage Route53 records for ACME DNS-01"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = "arn:aws:route53:::hostedzone/${data.aws_route53_zone.this.zone_id}"
      },
      {
        Effect   = "Allow"
        Action   = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:GetChange",
          "route53:ListHostedZonesByName"
        ]
        Resource = "*"
      }
    ]
  })
}

# Use the same IAM module submodule that worked for you earlier (v5.x)
module "irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.60.0"

  create_role = true
  role_name   = "${var.cluster_name}-certmanager-irsa"

  # Convert issuer URL to provider_url format (no https://)
  provider_url = replace(var.cluster_oidc_issuer_url, "https://", "")

  # Allow only the cert-manager SA in cert-manager ns
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:cert-manager:cert-manager"
  ]

  role_policy_arns           = [aws_iam_policy.certmanager_route53.arn]
  number_of_role_policy_arns = 1
}

output "role_arn" {
  value = module.irsa_role.iam_role_arn
}
output "zone_id" {
  value = data.aws_route53_zone.this.zone_id
}
