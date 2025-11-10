# output "grafana_ingress_host" {
#   description = "Grafana URL"
#   value       = "grafana.${var.domain}"
# }

# output "grafana_ingress_name" {
#   description = "Ingress resource name"
#   value       = kubernetes_ingress_v1.grafana.metadata[0].name
# }

output "host" {
  value = "grafana.${var.domain}"
}
