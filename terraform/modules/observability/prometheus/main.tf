#########################################
# 1. Create Service Account for Prometheus
#########################################
resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name" = "prometheus"
    }
  }

  automount_service_account_token = true

  depends_on = [var.namespace]
}

#########################################
# 2. Kube Prometheus Stack (with Grafana enabled)
#########################################
resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version
  namespace  = var.namespace

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [
    var.namespace,
    kubernetes_service_account.prometheus
  ]
}

#########################################
# 3. Outputs
#########################################
output "prometheus_helm_status" {
  value = helm_release.prometheus_stack.status
}

output "prometheus_chart_version" {
  value = helm_release.prometheus_stack.version
}

output "grafana_url" {
  value = "https://grafana.${var.domain}"
}
