resource "kubernetes_secret" "argocd_git_repo" {
  metadata {
    name      = "repo-kkintech15"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    url      = var.repo_url
    username = var.github_username
    password = var.github_token
  }

  type = "Opaque"
}
