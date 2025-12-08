output "ingress_nginx_namespace" {
  description = "Namespace where ingress-nginx is installed"
  value       = var.namespace
}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = var.namespace
  }
}

output "ingress_nginx_hostname" {
  description = "DNS hostname of the ingress-nginx LoadBalancer"
  value       = try(
    data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname,
    null
  )
}

# Output the LB hostname
output "lb_dns_name" {
  description = "DNS hostname of the ingress-nginx LoadBalancer"
  value       = try(
    data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname,
    null
  )
}


