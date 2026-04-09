output "argocd_url" {
  description = "The URL where argocd is accessible"
  value       = "argocd.${var.domain}"
}
