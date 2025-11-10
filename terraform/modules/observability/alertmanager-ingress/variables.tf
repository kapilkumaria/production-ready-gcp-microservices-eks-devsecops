variable "domain" {
  description = "Base domain (e.g., kapilkumaria.com)"
  type        = string
}

variable "certificate_secret_name" {
  description = "TLS secret that cert-manager populates in 'monitoring' namespace"
  type        = string
  default     = "wildcard-kapilkumaria-com-tls"
}

variable "alertmanager_service_name" {
  description = "K8s Service name for Alertmanager UI"
  type        = string
  default     = "kube-prometheus-stack-alertmanager"
}

variable "alertmanager_service_port" {
  description = "Service port for Alertmanager UI"
  type        = number
  default     = 9093
}
