variable "name" {
  description = "Helm release name for ingress-nginx"
  type        = string
  default     = "ingress-nginx"
}

variable "namespace" {
  description = "Namespace for ingress controller"
  type        = string
  default     = "ingress-nginx"
}

variable "chart_version" {
  description = "Helm chart version for ingress-nginx"
  type        = string
  default     = "4.11.2"  # Latest stable as of Nov 2024
}

variable "service_annotations" {
  description = "Annotations for the Service (Load Balancer)"
  type        = map(string)
  default = {
    "service.beta.kubernetes.io/aws-load-balancer-type"              = "nlb" # or "nlb-ip"
    "service.beta.kubernetes.io/aws-load-balancer-scheme"            = "internet-facing"
    "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"         = "443"    
  }
}

