terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.11.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.16.0"
    }
  }
}

# Helm install Grafana
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace = "monitoring"
  version    = var.chart_version

  values = [
    yamlencode({
      adminUser     = var.grafana_admin_user
      adminPassword = var.grafana_admin_password

      persistence = {
        enabled = var.enable_persistence
        size    = var.storage_size
        storageClassName = var.storage_class
        accessModes      = ["ReadWriteOnce"]
      }

      service = {
        type = var.service_type # ClusterIP / LoadBalancer / NodePort
        port = 3000
      }

      limits = {
        cpu    = "200m"
        memory = "512Mi"
      }

      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name      = "Prometheus"
              type      = "prometheus"
              access    = "proxy"
              url       = var.prometheus_url
              isDefault = true
            }
          ]
        }
      }
    })
  ]
}
