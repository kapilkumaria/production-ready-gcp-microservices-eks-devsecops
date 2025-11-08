resource "helm_release" "ingress_nginx" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.chart_version

  create_namespace = true

  values = [
    file("${path.module}/values-nginx.yaml")
  ]

  # Optional: Attach an IRSA role if required (e.g., AWS Load Balancer Controller)
  dynamic "set" {
    for_each = var.service_annotations
    content {
      name  = "controller.service.annotations.${replace(set.key, ".", "\\.")}"
      value = set.value
    }
  }
}
