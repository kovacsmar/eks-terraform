# EKS Terraform Baseline

Baseline EKS cluster with Traefik ingress controller and ArgoCD for GitOps deployment.

> **Disclaimer:** This is not a production ready cluster. To make it production ready you have to do further configurations.

## Overview

This project provides a baseline Terraform configuration to deploy an Amazon EKS cluster with:

- VPC networking with public and private subnets
- EKS cluster with managed node group
- Traefik as ingress controller with TLS termination
- ArgoCD for GitOps-based application deployment

## Tech Stack

| Technology | Purpose                    |
| ---------- | -------------------------- |
| AWS EKS    | Managed Kubernetes cluster |
| Terraform  | Infrastructure as Code     |
| Traefik    | Ingress controller         |
| ArgoCD     | GitOps continuous delivery |
| Helm       | Kubernetes package manager |

## Security Features

- KMS encryption for Kubernetes secrets
- IRSA (IAM Roles for Service Accounts) for IAM permissions
- TLS termination at Traefik ingress (manual setup, for production use automated certificate generatin)
- Worker nodes in private subnets
- VPC endpoints for S3 (private access)

## Prerequisites

- AWS account with appropriate permissions
- Terraform >= 1.12.1
- kubectl installed
- AWS CLI configured with appropriate credentials
- TLS certificate and key files (PEM format)

## Project Structure

```
.
├── backend
│   ├── backend.tfvars
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfstate
│   └── variables.tf
├── LICENSE.md
├── README.md
└── terraform
    ├── backend.hcl
    ├── backend.tf
    ├── dev.tfvars
    ├── locals.tf
    ├── main.tf
    ├── modules
    │   ├── argocd
    │   │   ├── argocd-values.yaml
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   ├── eks
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   ├── traefik
    │   │   ├── main.tf
    │   │   ├── traefik-values.yaml
    │   │   └── variables.tf
    │   └── vpc
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    ├── outputs.tf
    ├── secrets
    │   ├── fullchain.pem
    │   └── privkey.pem
    ├── variables.tf
    └── versions.tf
```

## TLS Certificates

Wildcard (\*.your-domain.com) TLS certificates are required for deployment. Place your certificate and key files in `terraform/secrets/`:

```
terraform/secrets/
├── fullchain.pem    # TLS certificate
└── privkey.pem      # TLS private key
```

The paths can be customized via variables:

- `tls_cert_path` (default: `../../secrets/fullchain.pem`)
- `tls_key_path` (default: `../../secrets/privkey.pem`)

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/kovacsmar/eks-terraform.git
cd eks-terraform
```

### 2. Configure TLS certificates

Place your TLS certificate and key in `terraform/secrets/`:

- `fullchain.pem` - TLS certificate bundle
- `privkey.pem` - Private key

### 3. Set up backend

```bash
cd backend
```

Create a `backend.tfvars` file with your configuration:

```hcl
bucket_name = "my-bucket"
```

```bash
terraform plan -var-file=backend.tfvars
terraform apply -var-file=backend.tfvars
```

```bash
cd ..
```

**Warning:** This s3 backend resource is delete protected, if you want to destroy it you have to remove the lines:

```hcl
lifecycle {
  prevent_destroy = true
}
```

### 4. Initialize Terraform

Create a `backend.hcl` file with your backend configuration in the `terraform` directory:

```hcl
bucket       = "my-bucket"
key          = "eks/terraform.tfstate"
use_lockfile = true
region       = "eu-central-1"
```

```bash
cd terraform
terraform init -backend-config=backend.hcl
```

### 5. Create tfvars file

Create a `terraform.tfvars` file with your configuration:

```hcl
region              = "eu-central-1"
environment         = "dev"
cluster_name_prefix = "my-eks"
domain              = "example.com"
```

### 6. Plan and Apply

```bash
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### 7. Access ArgoCD

After deployment, get the ArgoCD admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Access ArgoCD at: `https://argocd.example.com` (output will provide the actual url of ArrgoCD)

## Variable Reference

### Root Variables

| Variable              | Description                           | Type   | Required |
| --------------------- | ------------------------------------- | ------ | -------- |
| `region`              | AWS region for deployment             | string | Yes      |
| `environment`         | Environment name (dev, staging, prod) | string | Yes      |
| `cluster_name_prefix` | Prefix for EKS cluster name           | string | Yes      |
| `domain`              | Base domain for ArgoCD and ingress    | string | Yes      |

### VPC Module Variables

| Variable             | Description    | Default       |
| -------------------- | -------------- | ------------- |
| `vpc_cidr`           | VPC CIDR block | `10.0.0.0/16` |
| `availability_zones` | List of AZs    | auto-detect   |

### EKS Module Variables

| Variable         | Description                 | Default          |
| ---------------- | --------------------------- | ---------------- |
| `instance_types` | EC2 instance type for nodes | `["t3a.medium"]` |
| `min_size`       | Minimum node count          | `2`              |
| `max_size`       | Maximum node count          | `3`              |
| `desired_size`   | Desired node count          | `2`              |

### Traefik Module Variables

| Variable        | Description                                  | Default                       |
| --------------- | -------------------------------------------- | ----------------------------- |
| `tls_cert_path` | Path to TLS certificate (relative to module) | `../../secrets/fullchain.pem` |
| `tls_key_path`  | Path to TLS private key (relative to module) | `../../secrets/privkey.pem`   |

## Outputs

| Output         | Description             |
| -------------- | ----------------------- |
| `cluster_name` | Name of the EKS cluster |
| `argocd_url`   | ArgoCD server URL       |

## Post Deploy

Now you have to do some manual steps to make the cluster working:

- Get the kubernetes configuration, replace `cluster_name` with the output value :

  ```bash
  aws eks update-kubeconfig --name cluster_name
  ```

- Set up the DNS of your domain that you have created the certificate for to point to `EXTERNAL-IP` of traefik service

  ```bash
  kubectl get service -n traefik traefik -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
  ```

- Get the ArgoCD password

  ```bash
  kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
  ```

> Now you are ready to deploy your application with ArgoCD

## Deploy Sample Application

After deploying the cluster, you can deploy the docker-workshop sample application via ArgoCD.

Create `docker-workshop-app.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: docker-workshop
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ghcr.io/kovacsmar
    chart: docker-workshop
    targetRevision: "0.1.0"
    helm:
      valuesObject:
        ingress:
          enabled: true
          className: traefik
          hosts:
            - host: docker-workshop.example.com
              paths:
                - path: /
                  pathType: Prefix
  destination:
    server: https://kubernetes.default.svc
    namespace: docker-workshop
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

```bash
kubectl apply -f docker-workshop-app.yaml
```

Access the application at: `https://docker-workshop.example.com`

## Cleanup

To destroy all resources:

```bash
terraform destroy -var-file=terraform.tfvars
```

**Warning:** This will destroy all resources including the EKS cluster and any applications deployed. Make sure to back up any data.

## Dependencies

This project uses the following Terraform modules:

- [terraform-aws-modules/vpc/aws](https://github.com/terraform-aws-modules/terraform-aws-vpc)
- [terraform-aws-modules/eks/aws](https://github.com/terraform-aws-modules/terraform-aws-eks)
- [terraform-aws-modules/iam/aws](https://github.com/terraform-aws-modules/terraform-aws-iam)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
