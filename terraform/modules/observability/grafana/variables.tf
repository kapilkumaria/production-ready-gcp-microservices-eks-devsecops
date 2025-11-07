variable "namespace" {
  type        = string
  default     = "monitoring"
  description = "Namespace to deploy Grafana"
}

variable "chart_version" {
  type        = string
  default     = "8.5.12"   # You can change to latest version
  description = "Grafana Helm chart version"
}

variable "grafana_admin_user" {
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  type        = string
  description = "Admin password for Grafana"
  sensitive   = true
}

variable "enable_persistence" {
  type        = bool
  default     = true
}

variable "storage_size" {
  type        = string
  default     = "10Gi"
}

variable "storage_class" {
  type        = string
  default     = "gp3"   # Or "gp2", or your custom StorageClass
}

variable "service_type" {
  type        = string
  default     = "LoadBalancer"
}

variable "prometheus_url" {
  type        = string
  description = "URL of Prometheus service inside cluster"
  default     = "http://kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090"
}
