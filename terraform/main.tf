#############################################
# Main Terraform file for Production EKS + GitOps
#############################################

data "aws_availability_zones" "available" {
  state = "available"
}

#############################################
# VPC
#############################################
module "vpc" {
  source             = "./modules/vpc"
  aws_region         = var.aws_region
  vpc_cidr           = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
}

#############################################
# IAM
#############################################
module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
  cluster_name = var.cluster_name
}

#############################################
# EKS Cluster
#############################################
module "eks" {
  source     = "./modules/eks"
  aws_region = var.aws_region

  project_name   = var.project_name
  environment    = var.environment
  cluster_name   = var.cluster_name
  cluster_version = var.cluster_version

  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_role_arn
  subnet_ids       = module.vpc.private_subnet_ids

  endpoint_public_access  = true
  endpoint_private_access = false

  instance_types = ["t3.large"]
  disk_size      = 20
  desired_size   = 2
  min_size       = 2
  max_size       = 4

  tags = { Owner = "kapil" }
}

#############################################
# IAM OIDC
#############################################
module "iam_oidc" {
  source       = "./modules/iam-oidc"
  cluster_name = module.eks.cluster_name
  depends_on   = [module.eks]
}

data "aws_caller_identity" "current" {}

#############################################
# IRSA for workloads (ECR Pull + Microservices)
#############################################
module "irsa" {
  source = "./modules/irsa"

  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn       = module.eks.oidc_provider_arn
  account_id              = data.aws_caller_identity.current.account_id

  depends_on = [module.eks]
}

#############################################
# Monitoring Stack
#############################################
module "monitoring" {
  source = "./modules/monitoring"

  cluster_name                       = module.eks.cluster_name
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data

  depends_on = [module.eks]
}

#############################################
# IRSA for Cert Manager + Route53
#############################################
module "irsa_cert_manager" {
  source = "./modules/irsa-cert-manager"

  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  domain                  = var.domain_name
}

#############################################
# Cert Manager + Issuer + Certificate
#############################################
module "cert_manager" {
  source        = "./modules/cert-manager"
  irsa_role_arn = module.irsa_cert_manager.cert_manager_irsa_role_arn
  depends_on = [
    module.irsa_cert_manager,
    module.eks
  ]
}

module "clusterissuer" {
  source = "./modules/clusterissuer"

  email           = "kapil.kumaria@gmail.com"
  domain          = var.domain_name
  route53_zone_id = module.irsa_cert_manager.zone_id
  irsa_role_arn   = module.irsa_cert_manager.role_arn
}

module "certificate" {
  source = "./modules/certificate"
}

#############################################
# Observability Stack
#############################################
module "prometheus" {
  source    = "./modules/observability/prometheus"
  namespace = "monitoring"
  domain    = var.domain_name
}

module "ebs_csi" {
  source = "./modules/observability/ebs-csi"

  cluster_name      = module.eks.cluster_name
  oidc_provider_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn = module.eks.oidc_provider_arn
}

module "storage" {
  source = "./modules/storage"
}

module "loki" {
  source    = "./modules/observability/loki"
  namespace = "monitoring"

  dependency_prometheus    = module.prometheus
  dependency_storage_class = module.storage
}

module "promtail" {
  source          = "./modules/observability/promtail"
  namespace       = "monitoring"
  dependency_loki = module.loki
}

module "kube_state_metrics" {
  source                = "./modules/observability/kube-state-metrics"
  namespace             = "monitoring"
  dependency_prometheus = module.prometheus
}

#############################################
# Ingress NGINX (NLB)
#############################################
module "ingress_nginx" {
  source = "./modules/ingress-nginx"

  service_annotations = {
    "service.beta.kubernetes.io/aws-load-balancer-type"   = "nlb"
    "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
  }
}

#############################################
# Alertmanager
#############################################
module "alertmanager" {
  source    = "./modules/observability/alertmanager"
  namespace = "monitoring"
}

#############################################
# Root Placeholder Ingress
#############################################
module "root_ingress" {
  source = "./modules/root-ingress"
  domain = var.domain_name
}

#############################################
# Route53 DNS
#############################################
module "route53" {
  source            = "./modules/route53"
  hosted_zone_id    = module.irsa_cert_manager.zone_id
  domain            = var.domain_name
  create_apex_alias = true

  # FROM ingress-nginx output (hostname of the NLB)
  nlb_dns_name       = module.ingress_nginx.ingress_nginx_hostname
  nlb_hosted_zone_id = "Z35SXDOTRQ7X7K" # NLB Zone ID (correct for us-east-1)

  additional_records = {
    gcp = {
      name = "gcp"  # produces gcp.kapilkumaria.com → <NLB DNS>
    }
  }
}

#############################################
# Ingresses for Observability
#############################################
module "alertmanager_ingress" {
  source = "./modules/observability/alertmanager-ingress"
  domain = var.domain_name
}

module "prometheus_ingress" {
  source = "./modules/observability/prometheus-ingress"
  domain = var.domain_name
}

#############################################
# ArgoCD + Ingress
#############################################
module "argocd" {
  source             = "./modules/argocd"
  namespace          = "argocd"
  helm_chart_version = "6.9.3"
  domain             = var.domain_name
}

module "argocd_ingress" {
  source    = "./modules/argocd-ingress"
  namespace = "argocd"
  domain    = var.domain_name

  depends_on = [module.argocd]
}

#############################################
# Frontend UI Ingress (Main App)
#############################################
module "frontend_ui_ingress" {
  source       = "./modules/frontend-ui-ingress"
  namespace    = "default"
  domain       = var.domain_name
  subdomain    = "gcp"
  service_name = "frontend-ui"
  service_port = 80

  depends_on = [
    module.ingress_nginx,
    module.clusterissuer
  ]
}
