output "prometheus_namespace" {
  description = "Namespace where Prometheus is deployed"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "prometheus_release_name" {
  description = "Helm release name"
  value       = helm_release.prometheus_stack.name
}
