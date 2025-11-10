terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }
}

# 1) Namespace for Argo CD
resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/name"      = "argocd"
      "app.kubernetes.io/managed-by"= "terraform"
    }
  }
}

# 2) Wildcard certificate in *argocd* namespace (staging for now)
#    Uses the same ClusterIssuer name you already have
resource "kubernetes_manifest" "argocd_wildcard_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "wildcard-${replace(var.domain, ".", "-")}"
      namespace = var.namespace
    }
    spec = {
      secretName = var.certificate_secret_name
      dnsNames   = [
        var.domain,
        "*.${var.domain}",
      ]
      issuerRef = {
        name = var.cluster_issuer_name
        kind = "ClusterIssuer"
      }
    }
  }

  depends_on = [
    kubernetes_namespace.this
  ]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.helm_chart_version
  namespace  = var.namespace
  create_namespace = false

  # We terminate TLS at NGINX; ArgoCD runs --insecure behind it on HTTP (port 80).
  # Ingress uses your wildcard cert secret in *argocd* namespace.
  set {
    name  = "server.insecure"
    value = "true"
  }

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "server.service.servicePortHttp"
    value = "80"
  }

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  # NGINX ingress class
  set {
    name  = "server.ingress.ingressClassName"
    value = "nginx"
  }

  # Host: argocd.yourdomain
  set {
    name  = "server.ingress.hosts[0]"
    value = "argocd.${var.domain}"
  }

  # TLS config for the ingress
  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = "argocd.${var.domain}"
  }
  set {
    name  = "server.ingress.tls[0].secretName"
    value = var.certificate_secret_name
  }

  # Harden some defaults
  set {
    name  = "dex.enabled"
    value = "false"
  }
  set {
    name  = "redis.enabled"
    value = "true"
  }

  # Tolerate chart upgrades smoothly
  timeout = 600

  depends_on = [
    kubernetes_namespace.this,
    kubernetes_manifest.argocd_wildcard_certificate
  ]
}

# 4) (Optional) Basic, empty AppProject to start cleanly organizing apps
resource "kubernetes_manifest" "default_project" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "default"
      namespace = var.namespace
      labels = {
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }
    spec = {
      description = "Default project"
      sourceRepos = ["*"]
      destinations = [
        {
          namespace = "*"
          server    = "https://kubernetes.default.svc"
        }
      ]
      clusterResourceWhitelist = [
        { group = "*", kind = "*" }
      ]
      namespaceResourceWhitelist = [
        { group = "*", kind = "*" }
      ]
    }
  }

  depends_on = [helm_release.argocd]
}
