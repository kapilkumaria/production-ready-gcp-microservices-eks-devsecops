output "prometheus_release_name" {
  description = "Helm release name"
  value       = helm_release.prometheus_stack.name
}

output "prometheus_namespace" {
  value = kubernetes_namespace.monitoring.metadata[0].name
}
