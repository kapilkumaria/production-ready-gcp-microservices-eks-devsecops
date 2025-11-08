terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
  }
}

resource "helm_release" "node_exporter" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-node-exporter"
  version    = var.chart_version

  create_namespace = var.create_namespace

  values = [file("${path.module}/values.yaml")]

  timeout     = 600
  wait        = true
  atomic      = true
}
