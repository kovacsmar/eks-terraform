resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "9.4.17"

  values = [templatefile("${path.module}/argocd-values.yaml", {
    domain = "argocd.${var.domain}"
  })]
}
