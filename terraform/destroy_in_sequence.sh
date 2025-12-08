#!/bin/bash
# --------------------------------------------------
# Terraform Destroy Sequence Script (Final Correct Version)
# Author: Kapil
# Purpose: Safely tear down full DevSecOps EKS stack
# --------------------------------------------------

set -e

LOG_FILE="terraform_destroy_$(date +%Y%m%d_%H%M%S).log"

echo "========================================"
echo "🔥 Starting Full Terraform Destroy Sequence"
echo "Log File: ${LOG_FILE}"
echo "========================================"
echo

# --------------------------------------------------
# Terraform Init
# --------------------------------------------------
if [ ! -d ".terraform" ]; then
  echo "🔧 Running 'terraform init'..."
  terraform init | tee -a $LOG_FILE
else
  echo "🔧 Terraform already initialized."
fi

# --------------------------------------------------
# Helper function
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
# DESTROY IN ***REVERSE*** ORDER OF APPLY
# --------------------------------------------------

# 1️⃣ APPLICATIONS & INGRESS (destroy first)
destroy_module "module.argocd_app_nginx"
destroy_module "module.argocd_ingress"
destroy_module "module.argocd"

# Frontend UI Ingress
destroy_module "module.frontend_ui_ingress"

# 2️⃣ INGRESSES (Monitoring)
destroy_module "module.grafana_ingress"
destroy_module "module.prometheus_ingress"
destroy_module "module.alertmanager_ingress"

# 3️⃣ ROUTE53 + INGRESS-NGINX
destroy_module "module.route53"
destroy_module "module.ingress_nginx"

# 4️⃣ OBSERVABILITY STACK
destroy_module "module.grafana"
destroy_module "module.prometheus"
destroy_module "module.alertmanager"
destroy_module "module.loki"
destroy_module "module.promtail"
destroy_module "module.kube_state_metrics"
destroy_module "module.monitoring"

# 5️⃣ CERT-MANAGER + TLS
destroy_module "module.certificate"
destroy_module "module.clusterissuer"
destroy_module "module.cert_manager"

# 6️⃣ IRSA ROLES
destroy_module "module.irsa_cert_manager"
destroy_module "module.irsa_role"

# 7️⃣ STORAGE + CSI
destroy_module "module.storage"
destroy_module "module.ebs_csi"

# 8️⃣ EKS + IAM + OIDC
destroy_module "module.iam_oidc"
destroy_module "module.eks"
destroy_module "module.iam"

# 9️⃣ VPC (Must ALWAYS be last!)
destroy_module "module.vpc"

echo
echo "========================================"
echo "🔥 Terraform Destroy Completed Successfully"
echo "📘 Logs saved to: ${LOG_FILE}"
echo "========================================"
