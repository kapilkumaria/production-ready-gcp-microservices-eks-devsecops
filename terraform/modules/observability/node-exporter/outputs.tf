output "node_exporter_status" {
  description = "Status of node-exporter Helm deployment"
  value       = helm_release.node_exporter.status
}
