variable "domain" { type = string }

resource "kubernetes_manifest" "am_cert" {
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

resource "kubernetes_ingress_v1" "alertmanager" {
  metadata {
    name      = "alertmanager"
    namespace = "monitoring"
    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }
  spec {
    tls {
      hosts       = ["alertmanager.${var.domain}"]
      secret_name = "wildcard-tls"
    }
    rule {
      host = "alertmanager.${var.domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "kube-prometheus-stack-alertmanager"
              port { number = 9093 }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.am_cert]
}
