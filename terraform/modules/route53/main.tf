data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = var.ingress_service_name
    namespace = var.ingress_namespace
  }
}

locals {
  lb_hostname = try(data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname, "")
}

# CNAMEs for subdomains -> NLB DNS
resource "aws_route53_record" "grafana" {
  zone_id = var.hosted_zone_id
  name    = "grafana.${var.domain}"
  type    = "CNAME"
  ttl     = 60
  records = [local.lb_hostname]
}

resource "aws_route53_record" "prometheus" {
  zone_id = var.hosted_zone_id
  name    = "prometheus.${var.domain}"
  type    = "CNAME"
  ttl     = 60
  records = [local.lb_hostname]
}

resource "aws_route53_record" "alertmanager" {
  zone_id = var.hosted_zone_id
  name    = "alertmanager.${var.domain}"
  type    = "CNAME"
  ttl     = 60
  records = [local.lb_hostname]
}

resource "aws_route53_record" "argocd" {
  zone_id = var.hosted_zone_id
  name    = "argocd.${var.domain}"
  type    = "CNAME"
  ttl     = 60
  records = [local.lb_hostname]
}

resource "aws_route53_record" "nginx" {
  zone_id = var.hosted_zone_id
  name    = "nginx.${var.domain}"
  type    = "CNAME"
  ttl     = 60
  records = [local.lb_hostname]
}

# # Optional: apex ALIAS (recommended)
# resource "aws_route53_record" "apex" {
#   count   = var.create_apex_alias && var.nlb_hosted_zone_id != "" ? 1 : 0
#   zone_id = var.hosted_zone_id
#   name    = var.domain
#   type    = "A"
#   alias {
#     name                   = local.lb_hostname
#     zone_id                = var.nlb_hosted_zone_id  # from aws elbv2 describe-load-balancers
#     evaluate_target_health = false
#   }
# }

output "ingress_lb_hostname" {
  value = local.lb_hostname
}
