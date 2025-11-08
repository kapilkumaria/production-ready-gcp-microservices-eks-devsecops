variable "namespace" {
  description = "Namespace to deploy Promtail"
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "Promtail Helm chart version"
  type        = string
  default     = "6.15.5"
}

variable "dependency_loki" {
  description = "Wait for Loki to be ready first"
  type        = any
  default     = null
}
