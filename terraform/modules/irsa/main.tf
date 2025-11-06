module "irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.60.0"

  create_role = true
  role_name   = "${var.cluster_name}-irsa-role"

  provider_url = replace(var.cluster_oidc_issuer_url, "https://", "")

  oidc_fully_qualified_subjects = ["system:serviceaccount:*:*"]

  role_policy_arns = []
  number_of_role_policy_arns = 0
}
