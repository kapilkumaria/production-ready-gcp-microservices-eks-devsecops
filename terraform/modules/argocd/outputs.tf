output "argocd_namespace" {
  value = var.namespace
}

output "argocd_host" {
  value = "argocd.${var.domain}"
}

output "argocd_tls_secret" {
  value = var.certificate_secret_name
}
