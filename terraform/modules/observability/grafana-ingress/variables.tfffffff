variable "domain" {
  description = "Base domain (e.g., kapilkumaria.com)"
  type        = string
}

variable "certificate_secret_name" {
  description = "TLS secret that cert-manager populates in 'monitoring' namespace"
  type        = string
  default     = "wildcard-kapilkumaria-com-tls"
}

variable "grafana_service_name" {
  description = "K8s Service name for Grafana"
  type        = string
  default     = "kube-prometheus-stack-grafana"
}

variable "grafana_service_port" {
  description = "Service port for Grafana"
  type        = number
  default     = 80
}
