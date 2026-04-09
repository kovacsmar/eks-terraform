locals {
  secret_name = "traefik-wildcard-cert"
}

resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true
  version          = "39.0.7"

  # values = [file("${path.module}/traefik-values.yaml")]
  values = [templatefile("${path.module}/traefik-values.yaml", {
    secretname = local.secret_name
  })]
}

resource "kubernetes_secret_v1" "traefik-cert" {
  metadata {
    name      = local.secret_name
    namespace = "traefik"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = file("${path.module}/${var.tls_cert_path}")
    "tls.key" = file("${path.module}/${var.tls_key_path}")
  }

  depends_on = [helm_release.traefik]
}
