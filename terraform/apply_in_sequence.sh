#!/bin/bash
# ---------------------------------------------
# Terraform Apply + ArgoCD Automation Script
# Author: Kapil (Final Correct Version + Dashboard Token Support)
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
# Helper: Apply module
# ---------------------------------------------
apply_module() {
  MODULE=$1
  echo "🚀 Applying ${MODULE}..."
  echo "$(date): Applying ${MODULE}" | tee -a $LOG_FILE
  terraform apply -target=${MODULE} -auto-approve | tee -a $LOG_FILE
  echo "✅ Completed ${MODULE}"
  sleep 6
}

# ---------------------------------------------
# 2️⃣ Apply Terraform Modules (in correct order)
# ---------------------------------------------

# Base Infra
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

# Monitoring + Observability
apply_module "module.monitoring"
apply_module "module.prometheus"
apply_module "module.grafana"
apply_module "module.loki"
apply_module "module.promtail"
apply_module "module.kube_state_metrics"
apply_module "module.ingress_nginx"
apply_module "module.route53"

# Ingress order matters
apply_module "module.alertmanager"
apply_module "module.alertmanager_ingress"
apply_module "module.prometheus_ingress"
apply_module "module.grafana_ingress"

# ArgoCD
apply_module "module.argocd"
apply_module "module.argocd_ingress"

# Sample app
apply_module "module.argocd_app_nginx"

echo "🎉 Terraform Apply complete. Moving to ArgoCD automation..."

# ---------------------------------------------
# 3️⃣ Update kubeconfig
# ---------------------------------------------
echo "🔧 Updating kubeconfig..."
aws eks update-kubeconfig --name prod-ready-eks --region us-east-1

# ---------------------------------------------
# 4️⃣ Wait for ArgoCD readiness
# ---------------------------------------------
echo "⏳ Waiting for ArgoCD server rollout..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s

# ---------------------------------------------
# 5️⃣ Apply App-of-Apps
# ---------------------------------------------
echo "🚀 Applying ArgoCD App-of-Apps (dev)..."
kubectl apply -f ../k8s-manifests/argocd-apps/dev/app-of-apps.yaml -n argocd
echo "🎯 App-of-Apps applied!"

# ---------------------------------------------
# 6️⃣ Login to ArgoCD (auto-retry)
# ---------------------------------------------
echo "🔐 Logging into ArgoCD..."

ARGOCD_SERVER="argocd.kapilkumaria.com"

for i in {1..10}; do
  ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
      -o jsonpath="{.data.password}" | base64 --decode 2>/dev/null || true)

  if [[ -n "$ARGOCD_PASSWORD" ]]; then
    argocd login "$ARGOCD_SERVER" \
      --username admin \
      --password "$ARGOCD_PASSWORD" \
      --insecure \
      --grpc-web && break
  fi

  echo "⏳ Waiting for ArgoCD admin secret... retry $i/10"
  sleep 6
done

# ---------------------------------------------
# 7️⃣ Register GitHub Repo in ArgoCD
# ---------------------------------------------
echo "🔐 Registering GitHub repo with ArgoCD..."

if [[ -z "$GITHUB_USERNAME" || -z "$GITHUB_PAT" ]]; then
  echo "❌ ERROR: Missing GitHub Credentials"
  echo "export GITHUB_USERNAME=\"kapilkumaria\""
  echo "export GITHUB_PAT=\"<PAT>\""
  exit 1
fi

argocd repo add https://github.com/kapilkumaria/production-ready-gcp-microservices-eks-devsecops.git \
  --username "$GITHUB_USERNAME" \
  --password "$GITHUB_PAT" \
  --insecure \
  --grpc-web || true

echo "✅ GitHub repo registered!"

# ---------------------------------------------
# 8️⃣ Sync the root app
# ---------------------------------------------
echo "🔄 Triggering sync for root app dev-apps..."
argocd app sync dev-apps --grpc-web || true

# ---------------------------------------------
# 9️⃣ Generate Kubernetes Dashboard Token (EKS modern method)
# ---------------------------------------------
echo
echo "⏳ Waiting for Kubernetes Dashboard namespace..."
kubectl wait --for=condition=Ready pod -n kubernetes-dashboard --timeout=120s 2>/dev/null || true

echo "🔐 Generating Kubernetes Dashboard token (new Kubernetes method)..."

# Generate a token with a 10h TTL
DASHBOARD_TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user --duration=10h 2>/dev/null || true)

if [[ -z "$DASHBOARD_TOKEN" ]]; then
  echo "⚠️  Dashboard token not ready yet. Waiting 10 seconds..."
  sleep 10
  DASHBOARD_TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user 2>/dev/null || true)
fi

if [[ -z "$DASHBOARD_TOKEN" ]]; then
  echo "❌ ERROR: Failed to generate Dashboard token."
else
  echo "========================================"
  echo "📌 Kubernetes Dashboard URL:"
  echo "➡️  https://dashboard.kapilkumaria.com"
  echo
  echo "🔐 Dashboard Login Token:"
  echo "$DASHBOARD_TOKEN"
  echo "========================================"
fi

# ---------------------------------------------
# 🎉 Finish
# ---------------------------------------------
echo
echo "========================================"
echo "✅ Full Environment Deployed Successfully"
echo "🎉 All microservices + Dashboard deployed via ArgoCD!"
echo "📘 Logs saved to: ${LOG_FILE}"
echo "========================================"
