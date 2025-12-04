#!/bin/bash
# ---------------------------------------------
# Terraform Apply Sequence Script (Auto-Fixed)
# Author: Kapil
# Purpose: Fully automate DevSecOps EKS + ArgoCD + App-of-Apps deployment
# ---------------------------------------------

set -e

LOG_FILE="terraform_apply_$(date +%Y%m%d_%H%M%S).log"

echo "========================================"
echo "🌍 Starting Full Terraform Apply Sequence"
echo "Log File: ${LOG_FILE}"
echo "========================================"
echo

# ---------------------------------------------
# 0️⃣ Ensure Helm repos exist
# ---------------------------------------------
echo "📦 Ensuring Helm repositories are configured..."
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver 2>/dev/null || true
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo add grafana https://grafana.github.io/helm-charts 2>/dev/null || true
helm repo update

# ---------------------------------------------
# 1️⃣ Terraform Init
# ---------------------------------------------
if [ ! -d ".terraform" ]; then
  echo "🔧 Running 'terraform init'..."
  terraform init | tee -a $LOG_FILE
else
  echo "🔧 Terraform already initialized."
fi

# ---------------------------------------------
# Helper: Apply specific module
# ---------------------------------------------
apply_module() {
  MODULE=$1
  echo "🚀 Applying ${MODULE}..."
  echo "$(date): Applying ${MODULE}" | tee -a $LOG_FILE
  terraform apply -target=${MODULE} -auto-approve | tee -a $LOG_FILE
  echo "✅ Completed ${MODULE}"
  sleep 8
}

# ---------------------------------------------
# 2️⃣ Apply Modules in Order
# ---------------------------------------------

# Base Infrastructure
apply_module "module.vpc"
apply_module "module.iam"
apply_module "module.eks"
apply_module "module.iam_oidc"
apply_module "module.ebs_csi"
apply_module "module.storage"
apply_module "module.irsa_role"
apply_module "module.irsa_cert_manager"

# Cert-manager + TLS
apply_module "module.cert_manager"
apply_module "module.clusterissuer"
apply_module "module.certificate"

# Monitoring
apply_module "module.monitoring"
apply_module "module.prometheus"
apply_module "module.grafana"
apply_module "module.loki"
apply_module "module.promtail"
apply_module "module.kube_state_metrics"
apply_module "module.ingress_nginx"
apply_module "module.route53"

# Ingresses
apply_module "module.prometheus_ingress"
apply_module "module.alertmanager_ingress"
apply_module "module.grafana_ingress"
apply_module "module.alertmanager"

# ArgoCD Installation
apply_module "module.argocd"
apply_module "module.argocd_ingress"

# ArgoCD Sample Nginx App
apply_module "module.argocd_app_nginx"

echo "🎉 Terraform Apply complete. Moving to ArgoCD automation..."

# ---------------------------------------------
# 3️⃣ Ensure kubeconfig is updated
# ---------------------------------------------
echo "🔧 Updating kubeconfig..."
aws eks update-kubeconfig --name prod-ready-eks --region us-east-1

# ---------------------------------------------
# 4️⃣ Wait for ArgoCD to be ready
# ---------------------------------------------
echo "⏳ Waiting for ArgoCD server to roll out..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s

# ---------------------------------------------
# 5️⃣ Apply App-of-Apps for microservices
# ---------------------------------------------
echo "🚀 Applying ArgoCD App-of-Apps (dev)..."
kubectl apply -f ../k8s-manifests/argocd-apps/dev/app-of-apps.yaml -n argocd

echo "🎯 App-of-Apps deployed successfully!"

# ---------------------------------------------
# 6️⃣ Optional: Auto-sync everything
# ---------------------------------------------
echo "🔄 Triggering ArgoCD sync for root app..."
argocd app sync dev-apps --grpc-web || true

echo
echo "========================================"
echo "✅ Full Environment Deployed Successfully"
echo "📘 Logs saved to: ${LOG_FILE}"
echo "🎉 All microservices will now appear in ArgoCD UI."
echo "========================================"
