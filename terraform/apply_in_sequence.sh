#!/bin/bash
# ---------------------------------------------
# Terraform Apply Sequence Script (Auto-Fixed)
# Author: Kapil
# Purpose: Rebuild full DevSecOps EKS + ArgoCD stack in order
# ---------------------------------------------

set -e

# Timestamped log file
LOG_FILE="terraform_apply_$(date +%Y%m%d_%H%M%S).log"

echo "========================================"
echo "🌍 Starting Full Terraform Apply Sequence"
echo "Log File: ${LOG_FILE}"
echo "========================================"
echo

# ---------------------------------------------
# 🔧 0. Ensure helm repos exist
# ---------------------------------------------
echo "📦 Ensuring Helm repositories are configured..."
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver 2>/dev/null || true
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo add grafana https://grafana.github.io/helm-charts 2>/dev/null || true
helm repo update

# ---------------------------------------------
# 🔧 1. Ensure terraform init is done
# ---------------------------------------------
if [ ! -d ".terraform" ]; then
  echo "🔧 Running 'terraform init' (first time setup)..."
  terraform init | tee -a $LOG_FILE
else
  echo "🔧 Terraform already initialized — skipping init."
fi

# ---------------------------------------------
# Helper Function
# ---------------------------------------------
apply_module() {
  MODULE=$1
  echo "🚀 Applying ${MODULE}..."
  echo "----------------------------------------" | tee -a $LOG_FILE
  echo "$(date): Applying ${MODULE}" | tee -a $LOG_FILE

  terraform apply -target=${MODULE} -auto-approve | tee -a $LOG_FILE || {
      echo "❌ ERROR applying ${MODULE}. Check logs."
      exit 1
  }

  echo "✅ Completed ${MODULE}" | tee -a $LOG_FILE
  echo "----------------------------------------" | tee -a $LOG_FILE
  sleep 10
}

# ---------------------------------------------
# 2️⃣ Apply Modules in Order
# ---------------------------------------------

# 1️⃣ Base Infrastructure
apply_module "module.vpc"
apply_module "module.iam"
apply_module "module.eks"
apply_module "module.iam_oidc"
apply_module "module.ebs_csi"
apply_module "module.storage"
apply_module "module.irsa_role"
apply_module "module.irsa_cert_manager"

# 2️⃣ Cert-Manager & TLS
apply_module "module.cert_manager"
apply_module "module.clusterissuer"
apply_module "module.certificate"

# 3️⃣ Monitoring & Observability
apply_module "module.monitoring"
apply_module "module.prometheus"
apply_module "module.grafana"
apply_module "module.loki"
apply_module "module.promtail"
apply_module "module.kube_state_metrics"
apply_module "module.ingress_nginx"
apply_module "module.route53"

# 4️⃣ Individual Monitoring Ingresses
apply_module "module.prometheus"
apply_module "module.alertmanager"
apply_module "module.grafana"
apply_module "module.prometheus_ingress"
apply_module "module.alertmanager_ingress"
apply_module "module.grafana_ingress"

# 5️⃣ ArgoCD + Ingress
apply_module "module.argocd.helm_release.argocd"
apply_module "module.argocd"
apply_module "module.argocd_ingress"

# 6️⃣ Sample NGINX App via ArgoCD
apply_module "module.argocd_app_nginx"

# ---------------------------------------------
# Finished
# ---------------------------------------------

echo
echo "========================================"
echo "✅ Terraform Apply Completed Successfully"
echo "📘 Logs saved to: ${LOG_FILE}"
echo "========================================"
