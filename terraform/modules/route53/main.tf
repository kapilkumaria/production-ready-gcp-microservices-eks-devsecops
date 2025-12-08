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

resource "aws_route53_record" "dashboard" {
  zone_id = var.hosted_zone_id
  name    = "dashboard.${var.domain}"
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

# Create additional records such as gcp.kapilkumaria.com
resource "aws_route53_record" "additional" {
  for_each = var.additional_records

  zone_id = var.hosted_zone_id
  name    = "${each.value.name}.${var.domain}"
  type    = "CNAME"
  ttl     = 60
  records = [var.nlb_dns_name]
}


output "ingress_lb_hostname" {
  value = local.lb_hostname
}
