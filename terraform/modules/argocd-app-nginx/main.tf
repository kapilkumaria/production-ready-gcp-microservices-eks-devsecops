terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
  }
}

# Create Argo CD Application for NGINX sample app
resource "kubernetes_manifest" "nginx_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "nginx-sample"
      namespace = var.argocd_namespace
      labels = {
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }
    spec = {
      project = "default"

      source = {
        repoURL        = var.repo_url
        targetRevision = var.target_revision
        path           = var.app_path
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.app_namespace
      }

      syncPolicy = {
        automated = {
          prune     = true
          selfHeal  = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  depends_on = [var.depends_upon]
}
