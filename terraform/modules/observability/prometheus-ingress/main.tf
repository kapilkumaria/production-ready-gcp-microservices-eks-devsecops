# variable "domain" {}

resource "kubernetes_ingress_v1" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "monitoring"
    annotations = {
      "kubernetes.io/ingress.class"              = "nginx"
      "cert-manager.io/cluster-issuer"           = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  spec {
    rule {
      host = "prometheus.${var.domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "kube-prometheus-stack-prometheus"
              port { number = 9090 }
            }
          }
        }
      }
    }

    tls {
      secret_name = "wildcard-tls"
      hosts       = ["prometheus.${var.domain}"]
    }
  }
}
