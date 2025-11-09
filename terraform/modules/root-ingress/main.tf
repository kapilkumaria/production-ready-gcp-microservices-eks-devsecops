resource "kubernetes_deployment_v1" "root_nginx" {
  metadata {
    name      = "root-nginx"
    namespace = "default"
    labels = {
      app = "root-nginx"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "root-nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "root-nginx"
        }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx:stable"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "root_nginx" {
  metadata {
    name      = "root-nginx"
    namespace = "default"
  }
  spec {
    selector = {
      app = "root-nginx"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "root_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "wildcard-tls"
      namespace = "default"
    }
    spec = {
      secretName = "wildcard-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        var.domain,
        "*.${var.domain}"
      ]
    }
  }
}

resource "kubernetes_ingress_v1" "root_ingress" {
  metadata {
    name      = "root-ingress"
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    tls {
      hosts       = [var.domain]
      secret_name = "wildcard-tls"
    }
    rule {
      host = var.domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.root_nginx.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.root_cert]
}
