#!/bin/bash
# --------------------------------------------------
# Terraform Destroy Sequence Script (Final Correct)
# Author: Kapil
# Purpose: Tear down full DevSecOps EKS stack safely
# --------------------------------------------------

set -e

LOG_FILE="terraform_destroy_$(date +%Y%m%d_%H%M%S).log"

echo "========================================"
echo "🔥 Starting Full Terraform Destroy Sequence"
echo "Log File: ${LOG_FILE}"
echo "========================================"
echo

# --------------------------------------------------
# Init Terraform if needed
# --------------------------------------------------
if [ ! -d ".terraform" ]; then
  echo "🔧 Running 'terraform init'..."
  terraform init | tee -a $LOG_FILE
else
  echo "🔧 Terraform already initialized."
fi

# --------------------------------------------------
# Helper
# --------------------------------------------------
destroy_module() {
  MODULE=$1
  echo "🧨 Destroying ${MODULE}..."
  echo "$(date): Destroying ${MODULE}" | tee -a $LOG_FILE

  terraform destroy -target=${MODULE} -auto-approve | tee -a $LOG_FILE || {
    echo "❌ ERROR destroying ${MODULE}. Check logs."
    exit 1
  }

  echo "✅ Destroyed ${MODULE}"
  echo "--------------------------------------------"
  sleep 5
}

# --------------------------------------------------
# MUST DESTROY IN PERFECT REVERSE ORDER OF APPLY
# --------------------------------------------------

# 7️⃣ ArgoCD resources
destroy_module "module.argocd_app_nginx"
destroy_module "module.argocd_ingress"
destroy_module "module.argocd"
destroy_module "module.argocd_repo"

# 6️⃣ Monitoring ingresses
destroy_module "module.grafana_ingress"
destroy_module "module.prometheus_ingress"
destroy_module "module.alertmanager_ingress"

# 5️⃣ Observability stack
destroy_module "module.alertmanager"
destroy_module "module.grafana"
destroy_module "module.prometheus"
destroy_module "module.loki"
destroy_module "module.promtail"
destroy_module "module.kube_state_metrics"
destroy_module "module.monitoring"
destroy_module "module.ingress_nginx"

# 4️⃣ TLS + Cert-Manager
destroy_module "module.certificate"
destroy_module "module.clusterissuer"
destroy_module "module.cert_manager"

# 3️⃣ IRSA roles
destroy_module "module.irsa_cert_manager"
destroy_module "module.irsa_role"
destroy_module "module.irsa"

# 2️⃣ Storage + CSI
destroy_module "module.storage"
destroy_module "module.ebs_csi"

# 1️⃣ EKS + IAM
destroy_module "module.iam_oidc"
destroy_module "module.eks"
destroy_module "module.iam"

# 0️⃣ Route53 + Root Ingress
destroy_module "module.route53"
destroy_module "module.root_ingress"

# -1️⃣ Final VPC (must always be last)
destroy_module "module.vpc"

echo
echo "========================================"
echo "🔥 Terraform Destroy Completed Successfully"
echo "📘 Logs saved to: ${LOG_FILE}"
echo "========================================"
