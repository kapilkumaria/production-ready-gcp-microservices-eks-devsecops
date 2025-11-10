terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.0"
    }
  }
}

# Create Secret from alertmanager yaml
resource "kubernetes_secret" "alertmanager_config" {
  metadata {
    name      = "alertmanager-config"
    namespace = var.namespace
  }

  data = {
    "alertmanager.yaml" = file("${path.module}/files/alertmanager.yaml")
  }

  type = "Opaque"
}

# Deploy Alertmanager via Helm (standalone)
resource "helm_release" "alertmanager" {
  name       = "alertmanager"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "alertmanager"
  namespace  = var.namespace
  version    = "1.9.0"

  values = [
    yamlencode({
      configMapOverrideName = null
      alertmanagerSpec = {
        configSecret = kubernetes_secret.alertmanager_config.metadata[0].name
      }
      service = {
        type = "ClusterIP"
        port = 9093
      }
    })
  ]

  depends_on = [
    kubernetes_secret.alertmanager_config
  ]
}
