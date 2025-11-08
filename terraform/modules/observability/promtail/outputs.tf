output "promtail_status" {
  description = "Promtail deployed in namespace"
  value       = "Promtail is deployed in namespace ${var.namespace}"
}
