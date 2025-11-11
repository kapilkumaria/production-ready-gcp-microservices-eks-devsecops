variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "AL2_x86_64" # Ubuntu 24 AMI
}

variable "project_name" {
  description = "Project name used for tagging/naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, stage, prod)"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
  # default     = "1.30"
}

variable "cluster_role_arn" {
  description = "IAM role ARN for the EKS control plane"
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for the EKS managed node group"
  type        = string
}

variable "subnet_ids" {
  description = "List of PRIVATE subnet IDs for EKS and nodes"
  type        = list(string)
}

variable "endpoint_public_access" {
  description = "Enable public access to the EKS API endpoint"
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Enable private access to the EKS API endpoint"
  type        = bool
  default     = false
}

# Node Group settings
variable "instance_types" {
  description = "Instance types for the node group"
  type        = list(string)
  default     = ["t3.large"]
}

variable "disk_size" {
  description = "Node group disk size (GiB)"
  type        = number
  default     = 20
}

variable "desired_size" {
  description = "Desired node count for the node group"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum node count for the node group"
  type        = number
  default     = 3
}

variable "max_size" {
  description = "Maximum node count for the node group"
  type        = number
  default     = 5
}

variable "tags" {
  description = "Extra tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {}
