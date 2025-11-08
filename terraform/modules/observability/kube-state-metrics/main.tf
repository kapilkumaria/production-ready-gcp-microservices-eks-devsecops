resource "helm_release" "kube_state_metrics" {
  name       = "kube-state-metrics"
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  version    = var.chart_version

  create_namespace = true

  depends_on = [
    var.dependency_prometheus   # Ensures Prometheus is installed first
  ]
}
