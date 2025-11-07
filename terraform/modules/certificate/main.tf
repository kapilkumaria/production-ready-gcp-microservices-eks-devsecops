resource "kubernetes_manifest" "wildcard_certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "wildcard-kapilkumaria-com"
      "namespace" = "default" # Or use another namespace if ingress is elsewhere
    }
    "spec" = {
      "secretName" = "wildcard-kapilkumaria-com-tls"
      "dnsNames" = [
        "kapilkumaria.com",
        "*.kapilkumaria.com"
      ]
      "issuerRef" = {
        "name" = "letsencrypt-production"
        "kind" = "ClusterIssuer"
      }
    }
  }
}
