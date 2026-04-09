variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "cluster_name_prefix" {
  description = "Prefix for EKS cluster name (will be prefix-environment)"
  type        = string
}

variable "domain" {
  description = "Base domain for ArgoCD and ingress"
  type        = string
}