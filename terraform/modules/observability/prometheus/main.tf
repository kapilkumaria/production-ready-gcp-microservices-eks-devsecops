#########################################
# 1. Create Monitoring Namespace
#########################################
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "app.kubernetes.io/name" = "monitoring"
    }
  }
}

#########################################
# 2. Create Service Account for Prometheus (optional but recommended)
#########################################
resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "prometheus"
    }
  }

  automount_service_account_token = true

  depends_on = [kubernetes_namespace.monitoring]
}

#########################################
# 3. Deploy Prometheus Stack using Helm
#########################################
resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "61.4.0"

  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  # Ensure values.yaml exists in this module folder
  values = [
    file("${path.module}/values.yaml")
  ]

  # This makes sure the namespace exists before installation
  depends_on = [
    kubernetes_namespace.monitoring,
    kubernetes_service_account.prometheus
  ]
}

#########################################
# 4. (Optional) Output Prometheus Endpoint & Namespace
#########################################
output "prometheus_namespace" {
  value = kubernetes_namespace.monitoring.metadata[0].name
}

output "prometheus_helm_status" {
  value = helm_release.prometheus_stack.status
}

output "prometheus_chart_version" {
  value = helm_release.prometheus_stack.version
}
