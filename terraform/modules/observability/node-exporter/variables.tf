variable "name" {
  description = "Helm release name"
  type        = string
  default     = "node-exporter"
}

variable "namespace" {
  description = "Namespace to deploy node-exporter"
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "Helm chart version for node-exporter"
  type        = string
  default     = "4.36.0" # Latest as of Nov 2024
}

variable "create_namespace" {
  description = "Set to true if namespace doesn't exist"
  type        = bool
  default     = false
}
