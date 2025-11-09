output "grafana_fqdn"      { value = "grafana.${var.domain}" }
output "prometheus_fqdn"   { value = "prometheus.${var.domain}" }
output "alertmanager_fqdn" { value = "alertmanager.${var.domain}" }
output "apex_created"      { value = var.create_apex_alias && var.nlb_hosted_zone_id != "" }
