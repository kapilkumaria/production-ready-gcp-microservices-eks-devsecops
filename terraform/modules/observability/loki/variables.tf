variable "namespace" {
  description = "Namespace to deploy Loki"
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "Loki Helm chart version"
  type        = string
  default     = "5.36.3"
}

variable "dependency_prometheus" {
  description = "Wait for Prometheus to deploy"
  type        = any
  default     = null
}

variable "dependency_storage_class" {
  description = "Wait for gp3 StorageClass"
  type        = any
  default     = null
}

