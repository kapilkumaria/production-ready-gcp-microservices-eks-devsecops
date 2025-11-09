variable "namespace" {
  description = "Namespace to deploy Prometheus stack"
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "Version of kube-prometheus-stack Helm chart"
  type        = string
  default     = "65.1.0" # Adjust to latest stable if needed
}

variable "domain" {}