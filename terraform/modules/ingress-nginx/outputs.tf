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

output "lb_dns_name" {
  description = "Load balancer DNS name"
  value       = kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
}

output "lb_zone_id" {
  description = "Load balancer hosted zone ID"
  value       = kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].zone_id
}

