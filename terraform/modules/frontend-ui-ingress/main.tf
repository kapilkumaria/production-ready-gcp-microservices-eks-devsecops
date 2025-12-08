resource "kubernetes_ingress_v1" "frontend" {
  metadata {
    name      = "frontend-ui-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = ["${var.subdomain}.${var.domain}"]
      secret_name = "frontend-ui-tls"
    }

    rule {
      host = "${var.subdomain}.${var.domain}"

      http {
        path {
          path     = "/"
          path_type = "Prefix"

          backend {
            service {
              name = var.service_name
              port {
                number = var.service_port
              }
            }
          }
        }
      }
    }
  }
}
