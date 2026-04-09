variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where EKS will be deployed"
  type        = string
}

variable "subnets" {
  description = "List of private subnet IDs for EKS cluster"
  type        = list(string)
}

variable "instance_types" {
  description = "List of instance types for EKS cluster"
  default     = ["t3a.medium"]
  type        = list(string)
}

variable "min_size" {
  description = "The minimum number of nodes that the managed node group can scale in to"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "The maximum number of nodes that the managed node group can scale out to"
  type        = number
  default     = 3

}

variable "desired_size" {
  description = " The current number of nodes that the managed node group should maintain"
  type        = number
  default     = 2
}

