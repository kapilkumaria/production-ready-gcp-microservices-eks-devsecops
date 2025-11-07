# Route53 Zone Lookup
data "aws_route53_zone" "this" {
  name         = var.domain
  private_zone = false
}

# IAM Policy for cert-manager (DNS-01 via Route53)
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

# IRSA Role for cert-manager
module "irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.60.0"

  create_role = true
  role_name   = "${var.cluster_name}-certmanager-irsa"

  provider_url = replace(var.cluster_oidc_issuer_url, "https://", "")

  oidc_fully_qualified_subjects = [
    "system:serviceaccount:cert-manager:cert-manager"
  ]

  role_policy_arns = [aws_iam_policy.certmanager_route53.arn]
}

# # ✅ Allow cert-manager to assume this role (self-assume)
# resource "aws_iam_role_policy" "self_assume" {
#   name = "${var.cluster_name}-allow-self-assume"
#   role = module.irsa_role.iam_role_name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = "sts:AssumeRole"
#         Resource = module.irsa_role.iam_role_arn
#       }
#     ]
#   })
# }


# Outputs
output "role_arn" {
  value = module.irsa_role.iam_role_arn
}

output "zone_id" {
  value = data.aws_route53_zone.this.zone_id
}
