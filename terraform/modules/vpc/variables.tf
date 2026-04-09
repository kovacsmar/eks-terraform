variable "vpc_name" {
  description = "Name of the VPC"
  default     = "eks-vpc"
  type        = string
}

variable "region" {
  description = "AWS region for the VPC"
  type        = string
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC, minimum /17 subnet needed to fit addresses"
  default     = "10.0.0.0/16"
  type        = string
}

