output "frontend_ui_ingress_name" {
  value = kubernetes_ingress_v1.frontend.metadata[0].name
}
