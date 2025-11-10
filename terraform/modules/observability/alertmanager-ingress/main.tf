# Alertmanager Ingress
resource "kubernetes_ingress_v1" "alertmanager" {
  metadata {
    name      = "alertmanager"
    namespace = "monitoring"

    annotations = {
      "kubernetes.io/ingress.class"              = "nginx"
      # IMPORTANT: must match your ClusterIssuer resource name
      # "cert-manager.io/cluster-issuer"           = "letsencrypt-production"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  spec {
    rule {
      host = "alertmanager.${var.domain}"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              # Confirm via: kubectl get svc -n monitoring | grep alertmanager
              name = var.alertmanager_service_name
              port { number = var.alertmanager_service_port }
            }
          }
        }
      }
    }

    tls {
      hosts       = ["alertmanager.${var.domain}"]
      secret_name = var.certificate_secret_name
    }
  }
}
