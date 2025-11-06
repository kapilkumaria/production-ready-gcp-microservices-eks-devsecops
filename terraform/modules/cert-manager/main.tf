resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = var.namespace
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.15.1"

  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  # Attach IRSA Role from input variable
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.irsa_role_arn
  }

  set {
    name  = "serviceAccount.name"
    value = "cert-manager"
  }
}
