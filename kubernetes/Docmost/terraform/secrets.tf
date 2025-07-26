# kubernetes/docmost/terraform/secrets.tf
locals {
  secrets = yamldecode(data.sops_file.secrets.raw)
}

resource "kubernetes_secret" "docmost" {
  metadata {
    name      = "docmost-secrets"
    namespace = var.namespace
  }
  type = "Opaque"
  data = {
    postgres-password = base64encode(local.secrets.postgres_password)
    app-secret        = base64encode(local.secrets.app_secret)
    jwt-secret        = base64encode(local.secrets.jwt_secret)
    database-url      = base64encode("postgresql://docmost:${local.secrets.postgres_password}@postgres:5432/docmost?schema=public")
  }
}
