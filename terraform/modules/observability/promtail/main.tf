resource "helm_release" "promtail" {
  name       = "promtail"
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = var.chart_version

  create_namespace = true

  values = [
    file("${path.module}/values-promtail.yaml")
  ]

  depends_on = [
    var.dependency_loki
  ]
}
