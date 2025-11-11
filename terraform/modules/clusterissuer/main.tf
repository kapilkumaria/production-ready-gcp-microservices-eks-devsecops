resource "kubernetes_manifest" "cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = { name = "letsencrypt-production" }
    spec = {
      acme = {
        email  = var.email
        server = "https://acme-v02.api.letsencrypt.org/directory"
        # server: "https://acme-staging-v02.api.letsencrypt.org/directory"

        privateKeySecretRef = { name = "letsencrypt-prod-private-key" }
        solvers = [
          {
            selector = { dnsZones = ["kapilkumaria.com"] }
            dns01 = {
              route53 = {
                region       = "us-east-1"
                hostedZoneID = var.route53_zone_id
                # role = var.irsa_role_arn   # ❌ REMOVE THIS LINE
              }
            }
            # Optional, fine to keep, but not necessary for IRSA:
            podTemplate = {
              spec = {
                serviceAccountName = "cert-manager"
              }
            }
          }
        ]
      }
    }
  }

  field_manager { force_conflicts = true }
}
