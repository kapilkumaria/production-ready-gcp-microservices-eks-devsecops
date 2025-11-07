resource "helm_release" "loki" {
  name       = "loki"
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = var.chart_version

  values = [
    file("${path.module}/values-loki.yaml")
  ]

  depends_on = [
    var.dependency_prometheus,
    var.dependency_storage_class
  ]
}
