variable "vpc_name" {
  description = "The name of the VPC used by EKS."
  default     = "eks-vpc"
  type        = string
}

variable "region" {
  description = "The region where the VPC is created."
  type        = string
}

variable "environment" {
  description = "Environment tag of VPC."
  type        = string
}

variable "cluster_name" {
  description = "The EKS cluster name that uses the VPC."
  type        = string
}
