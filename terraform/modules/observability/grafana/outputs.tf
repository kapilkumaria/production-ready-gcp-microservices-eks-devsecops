output "grafana_service" {
  description = "Expose Grafana service details"
  value       = helm_release.grafana.status
}

# If you still want the URL later, but only when LoadBalancer exists:
# output "grafana_url" {
#   description = "Grafana LoadBalancer URL if created"
#   value       = try(helm_release.grafana.status.load_balancer[0].ingress[0], null)
# }

output "grafana_admin_user" {
  value = var.grafana_admin_user
}

output "grafana_namespace" {
  value = "monitoring"
}
