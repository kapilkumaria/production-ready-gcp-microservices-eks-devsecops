variable "namespace" {
  description = "Namespace for kube-state-metrics"
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "Helm chart version for kube-state-metrics"
  type        = string
  default     = "5.27.0"  # latest stable
}

variable "dependency_prometheus" {
  description = "Deploy only after Prometheus"
  type        = any
  default     = null
}
