terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11.0"
    }
  }
}

# Create namespace if not exist
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

# Deploy kube-prometheus-stack (Prometheus + Alertmanager + Node Exporter + Grafana bundled)
resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version

  values = [
    yamlencode({
      grafana = {
        enabled = false  # Because you are installing Grafana separately
      }
      alertmanager = {
        enabled = true
      }
      prometheus = {
        prometheusSpec = {
          retention = "15d"
          serviceMonitorSelectorNilUsesHelmValues = true
        }
      }
    })
  ]
}
