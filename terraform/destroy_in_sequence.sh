#!/bin/bash
# --------------------------------------------------
# Terraform Destroy Sequence Script
# Author: Kapil
# Purpose: Tear down the full DevSecOps EKS stack
# --------------------------------------------------

set -e

LOG_FILE="terraform_destroy_$(date +%Y%m%d_%H%M%S).log"

echo "========================================"
echo "🔥 Starting Full Terraform Destroy Sequence"
echo "Log File: ${LOG_FILE}"
echo "========================================"
echo

# ---------------------------------------------
# 🔧 Ensure terraform init is done
# ---------------------------------------------
if [ ! -d ".terraform" ]; then
  echo "🔧 Running 'terraform init'..."
  terraform init | tee -a $LOG_FILE
fi

# ---------------------------------------------
# Helper Function
# ---------------------------------------------
destroy_module() {
  MODULE=$1
  echo "🧨 Destroying ${MODULE}..."
  echo "----------------------------------------" | tee -a $LOG_FILE
  echo "$(date): Destroying ${MODULE}" | tee -a $LOG_FILE

  terraform destroy -target=${MODULE} -auto-approve | tee -a $LOG_FILE || {
      echo "❌ ERROR destroying ${MODULE}. Check logs."
      exit 1
  }

  echo "✅ Destroyed ${MODULE}" | tee -a $LOG_FILE
  echo "----------------------------------------" | tee -a $LOG_FILE
  sleep 5
}

# ---------------------------------------------
# 1️⃣ Destroy in REVERSE ORDER of apply
# ---------------------------------------------

# 6️⃣ ArgoCD Sample app
destroy_module "module.argocd_app_nginx"

# 5️⃣ ArgoCD + Ingress
destroy_module "module.argocd_ingress"
destroy_module "module.argocd"

# 4️⃣ Monitoring Ingresses
destroy_module "module.grafana_ingress"
destroy_module "module.alertmanager_ingress"
destroy_module "module.prometheus_ingress"

# 3️⃣ Observability Stack
destroy_module "module.alertmanager"
destroy_module "module.grafana"
destroy_module "module.prometheus"
destroy_module "module.loki"
destroy_module "module.promtail"
destroy_module "module.kube_state_metrics"
destroy_module "module.ingress_nginx"
destroy_module "module.monitoring"

# 2️⃣ Cert-Manager & TLS
destroy_module "module.certificate"
destroy_module "module.clusterissuer"
destroy_module "module.cert_manager"
destroy_module "module.irsa_cert_manager"

# 1️⃣ IRSA, Storage, EBS CSI
destroy_module "module.irsa_role"
destroy_module "module.storage"
destroy_module "module.ebs_csi"

# 0️⃣ EKS dependencies
destroy_module "module.iam_oidc"
destroy_module "module.eks"
destroy_module "module.iam"

# -1️⃣ Final: VPC (must be last)
destroy_module "module.vpc"

echo
echo "========================================"
echo "🔥 Terraform Destroy Completed Successfully"
echo "📘 Logs saved to: ${LOG_FILE}"
echo "========================================"
