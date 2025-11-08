output "alertmanager_service" {
  description = "Alertmanager service details"
  value       = "kubectl port-forward svc/alertmanager -n ${var.namespace} 9093"
}

output "alertmanager_url" {
  value = "http://localhost:9093"
}
