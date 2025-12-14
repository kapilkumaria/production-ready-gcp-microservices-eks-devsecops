# Grafana Ingress (Terraform-managed)
resource "kubernetes_ingress_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "monitoring"

    annotations = {
      "kubernetes.io/ingress.class"              = "nginx"
      # "cert-manager.io/cluster-issuer"           = "letsencrypt-production"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  spec {
    rule {
      host = "grafana.${var.domain}"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = var.grafana_service_name
              port { number = var.grafana_service_port }
            }
          }
        }
      }
    }

    tls {
      hosts       = ["grafana.${var.domain}"]
      secret_name = var.certificate_secret_name
    }
  }
}
