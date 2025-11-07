output "loki_service_url" {
  description = "Internal Loki service endpoint"
  value       = "http://loki.${var.namespace}.svc.cluster.local:3100"
}
