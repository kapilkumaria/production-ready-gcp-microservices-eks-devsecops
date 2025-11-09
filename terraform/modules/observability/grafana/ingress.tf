variable "domain" { type = string }

resource "kubernetes_manifest" "grafana_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "wildcard-tls"
      namespace = "monitoring"
    }
    spec = {
      secretName  = "wildcard-tls"
      issuerRef   = { kind = "ClusterIssuer", name = "letsencrypt-prod" }
      dnsNames    = ["*.${var.domain}"]
    }
  }
}

resource "kubernetes_ingress_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "monitoring"
    annotations = {
      "kubernetes.io/ingress.class"          = "nginx"
      "cert-manager.io/cluster-issuer"       = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }
  spec {
    tls {
      hosts       = ["grafana.${var.domain}"]
      secret_name = "wildcard-tls"
    }
    rule {
      host = "grafana.${var.domain}"
      http {
        path {
          path     = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "grafana"
              port { number = 3000 }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.grafana_cert]
}
