data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module Call
module "vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
  vpc_cidr   = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
}

# IAM Module Call
module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
  cluster_name = var.cluster_name
}

# EKS Module Call
module "eks" {
  source = "./modules/eks"
  aws_region = var.aws_region

  project_name   = var.project_name
  environment    = var.environment

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  cluster_role_arn   = module.iam.eks_cluster_role_arn
  node_role_arn      = module.iam.eks_node_role_arn
  subnet_ids         = module.vpc.private_subnet_ids

  # Endpoint access strategy
  endpoint_public_access  = true
  endpoint_private_access = false

  # Node group config
  instance_types = ["t3.medium"]
  disk_size      = 20
  desired_size   = 2
  min_size       = 2
  max_size       = 4

  tags = {
    Owner = "kapil"
  }
}

module "iam_oidc" {
  source       = "./modules/iam-oidc"
  cluster_name = module.eks.cluster_name
  depends_on   = [module.eks]
}


# Fetch cluster OIDC info
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

# IRSA Module Call
data "aws_caller_identity" "current" {}

module "irsa" {
  source = "./modules/irsa"

  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn       = module.eks.oidc_provider_arn
  account_id              = data.aws_caller_identity.current.account_id
}

# Monitoring Module Call
module "monitoring" {
  source = "./modules/monitoring"

  cluster_name = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data

  depends_on = [module.eks] # Ensure EKS is created before Helm chart deployment
}

# IRSA for cert-manager Module Call
module "irsa_cert_manager" {
  source = "./modules/irsa-cert-manager"

  cluster_name              = module.eks.cluster_name
  cluster_oidc_issuer_url  = module.eks.cluster_oidc_issuer_url
  domain                   = var.domain_name   # e.g. "kapilkumaria.com"
}

# Cert-Manager Module Call
module "cert_manager" {
  source       = "./modules/cert-manager"
  irsa_role_arn = module.irsa_cert_manager.cert_manager_irsa_role_arn  # <-- Uses output from IRSA module

  depends_on = [
    module.irsa_cert_manager,
    module.eks
  ]
}

# ClusterIssuer Module Call
module "clusterissuer" {
  source = "./modules/clusterissuer"

  email                = "youremail@gmail.com"
  domain               = var.domain_name
  route53_zone_id      = module.irsa_cert_manager.zone_id
  irsa_role_arn        = module.irsa_cert_manager.role_arn
}

# Certificate Module Call
module "certificate" {
  source = "./modules/certificate"
}

# Prometheus Module Call
module "prometheus" {
  source    = "./modules/observability/prometheus"
  namespace = "monitoring"
  domain = var.domain_name
}

# Grafana Module Call
module "grafana" {
  source                 = "./modules/observability/grafana"
  namespace              = "monitoring"
  grafana_admin_password = "Kapil123!"
  # domain = var.domain_name
}

# EBS CSI Module Call
# EBS CSI (must come before any PVC-using apps)
module "ebs_csi" {
  source = "./modules/observability/ebs-csi"

  cluster_name      = module.eks.cluster_name
  oidc_provider_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn = module.eks.oidc_provider_arn
}

# Storage Module Call
module "storage" {
  source = "./modules/storage"  
}

# Loki Module Call
module "loki" {
  source    = "./modules/observability/loki"
  namespace = "monitoring"

  dependency_prometheus    = module.prometheus
  dependency_storage_class = module.storage
}

# Promtail Module Call
module "promtail" {
  source             = "./modules/observability/promtail"
  namespace          = "monitoring"
  dependency_loki    = module.loki
}


# Kube-State-Metrics Module Call
module "kube_state_metrics" {
  source                = "./modules/observability/kube-state-metrics"
  namespace             = "monitoring"
  dependency_prometheus = module.prometheus
}


# Ingress-NGINX Module Call
module "ingress_nginx" {
  source = "./modules/ingress-nginx"

  service_annotations = {
    "service.beta.kubernetes.io/aws-load-balancer-type"   = "nlb"
    "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
  }
}

# # Node Exporter Module Call
# module "node_exporter" {
#   source    = "./modules/observability/node-exporter"
#   namespace = "monitoring"
# }

# Alertmanager Module Call
module "alertmanager" {
  source    = "./modules/observability/alertmanager"
  namespace = "monitoring"
  # domain = var.domain_name
}

# Ingresses already live under their respective modules (as shown above)
# module "grafana_ingress" {
#   source = "./modules/observability/grafana"
#   domain = var.domain_name
#   grafana_admin_password = "Kapil123!"
# }

# module "prometheus_ingress" {
#   source = "./modules/observability/prometheus"
#   # domain = var.domain_name
# }

# module "prometheus_ingress" {
#   source = "./modules/observability/prometheus/ingress"
#   domain = var.domain_name
# }

# module "prometheus_ingress" {
#   source = "./modules/observability/prometheus-ingress"
#   domain = var.domain_name
# }

# module "alertmanager_ingress" {
#   source = "./modules/observability/alertmanager"
#   domain = var.domain_name
# }

# Root placeholder ingress (optional, until your app is ready)
module "root_ingress" {
  source = "./modules/root-ingress" # (if you split it) — or keep inline in root
  domain = var.domain_name
}

# Route53
module "route53" {
  source            = "./modules/route53"
  hosted_zone_id    = module.irsa_cert_manager.zone_id  # you already output zone id there
  domain            = var.domain_name                   # "kapilkumaria.com"
  create_apex_alias = true
  # Set after you fetch it (see command above). For first run you can leave "" to skip apex record.
  nlb_hosted_zone_id = var.nlb_hosted_zone_id
}

# # Root Ingress Module Call
# module "root_ingress" {
#   source = "./modules/root-ingress"
#   domain = var.domain_name   # domain_name should be "kapilkumaria.com"
# }

# Alertmanager Ingress Module Call
module "alertmanager_ingress" {
  source = "./modules/observability/alertmanager-ingress"
  domain = var.domain_name   # Make sure your main.tf uses var.domain_name
}

module "grafana_ingress" {
  source = "./modules/observability/grafana-ingress"
  domain = var.domain_name
}


module "prometheus_ingress" {
  source = "./modules/observability/prometheus-ingress"
  domain = var.domain_name
}

resource "kubernetes_manifest" "delete_old_bad_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "wildcard-kapilkumaria-com-tls"
      namespace = "monitoring"
    }
  }

  lifecycle { ignore_changes = all }
}
