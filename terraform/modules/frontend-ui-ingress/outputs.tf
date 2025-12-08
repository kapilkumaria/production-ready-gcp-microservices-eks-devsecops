output "frontend_ui_ingress_name" {
  value = kubernetes_ingress_v1.frontend_ingress.metadata[0].name
}

output "frontend_ui_host" {
  value = var.domain
}
