module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = "1.35"

  endpoint_public_access = true
  create_kms_key         = true
  enable_irsa            = true

  encryption_config = {
    resources = ["secrets"]
  }

  enable_cluster_creator_admin_permissions = true

  cloudwatch_log_group_retention_in_days = 1

  compute_config = {
    enabled = false
  }
  eks_managed_node_groups = {
    general = {
      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size
    }
  }

  addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
    aws-ebs-csi-driver = {
      most_recent = true

      service_account_role_arn = module.ebs_csi_irsa.arn
    }
  }


  node_security_group_additional_rules = {
    ingress_traefik_http = {
      description = "Allow HTTP traffic to Traefik pods"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_traefik_https = {
      description = "Allow HTTPS traffic to Traefik pods"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  vpc_id     = var.vpc_id
  subnet_ids = var.subnets

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  name = "${var.cluster_name}-ebs-csi"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}
