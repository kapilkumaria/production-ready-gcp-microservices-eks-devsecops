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
      "app.kubernetes.io/name"       = "argocd"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# 2) Install Argo CD via Helm
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.helm_chart_version
  namespace        = var.namespace
  create_namespace = false
  timeout          = 600

  # Disable DEX for simplicity
  set {
    name  = "dex.enabled"
    value = "false"
  }

  # Keep Redis enabled
  set {
    name  = "redis.enabled"
    value = "true"
  }

  # Enable ingress - we'll manage details in argocd-ingress module
  set {
    name  = "server.ingress.enabled"
    value = "false"
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
    name  = "server.insecure"
    value = "true"
  }

  depends_on = [kubernetes_namespace.this]
}

# 3) Wait for CRDs to be ready (AppProject, Application, etc.)
resource "null_resource" "wait_for_argocd_crds" {
  provisioner "local-exec" {
    command = <<EOT
      echo "⏳ Waiting for ArgoCD CRDs to become available..."
      for i in {1..30}; do
        if kubectl get crd appprojects.argoproj.io &>/dev/null; then
          echo "✅ ArgoCD CRDs are ready."
          exit 0
        fi
        echo "Waiting for CRDs... attempt $i/30"
        sleep 10
      done
      echo "❌ Timeout waiting for ArgoCD CRDs to be installed."
      exit 1
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [helm_release.argocd]
}

# 4) Default Argo CD Project (applied only after CRDs exist)
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
      clusterResourceWhitelist = [{ group = "*", kind = "*" }]
      namespaceResourceWhitelist = [{ group = "*", kind = "*" }]
    }
  }

  depends_on = [
    null_resource.wait_for_argocd_crds,
    helm_release.argocd
  ]
}
