# output "alertmanager_ingress_host" {
#   description = "DNS hostname for accessing Alertmanager"
#   value       = "alertmanager.${var.domain}"
# }

# output "alertmanager_ingress_name" {
#   description = "Name of the Kubernetes ingress resource"
#   value       = kubernetes_ingress_v1.alertmanager.metadata[0].name
# }

output "host" {
  value = "alertmanager.${var.domain}"
}
