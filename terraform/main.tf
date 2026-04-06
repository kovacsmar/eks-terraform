provider "aws" {
  region = var.region
}

module "vpc" {
  source       = "./modules/vpc"
  region       = var.region
  environment  = var.environment
  cluster_name = local.cluster_name
}

module "eks" {
  source       = "./modules/eks"
  environment  = var.environment
  cluster_name = local.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnets      = module.vpc.private_subnet_ids
}
