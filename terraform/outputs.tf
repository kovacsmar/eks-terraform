output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "argocd_url" {
  description = "The URL where argocd is accessible"
  value       = module.argocd.argocd_url
}
