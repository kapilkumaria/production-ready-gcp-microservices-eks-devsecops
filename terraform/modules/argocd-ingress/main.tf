terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
  }
}

# ArgoCD ingress definition
resource "kubernetes_ingress_v1" "argocd" {
  metadata {
    name      = "argocd-server-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-production"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      # Add these critical annotations to fix the redirect loop
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "0"
      "nginx.ingress.kubernetes.io/proxy-buffer-size"  = "128k"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/connection-proxy-header" = "keep-alive"
      "nginx.ingress.kubernetes.io/proxy-connect-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      # Important for ArgoCD WebSocket connections
      "nginx.ingress.kubernetes.io/websocket-services" = "argocd-server"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "argocd.${var.domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    tls {
      hosts       = ["argocd.${var.domain}"]
      secret_name = "wildcard-kapilkumaria-com-tls"
    }
  }

  depends_on = [var.depends_upon]
}