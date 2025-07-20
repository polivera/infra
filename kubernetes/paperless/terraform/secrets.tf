locals {
  secrets = yamldecode(data.sops_file.secrets.raw)
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "postgres-secrets"
    namespace = var.namespace
  }
  type = "Opaque"
  data = {
    postgres-password = base64encode(local.secrets.postgres_password)
  }
}