variable "namespace" {
  type        = string
  description = "Namespace where frontend-ui service exists"
}

variable "domain" {
  type        = string
  description = "Domain name for ingress"
}

variable "service_name" {
  type        = string
  description = "Frontend UI service name"
}

variable "service_port" {
  type        = number
  default     = 80
}


