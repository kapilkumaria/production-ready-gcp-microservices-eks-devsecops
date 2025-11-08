output "kube_state_metrics_service_url" {
  description = "Service endpoint for kube-state-metrics"
  value       = "http://kube-state-metrics.${var.namespace}.svc.cluster.local:8080/metrics"
}
