# terraform/secrets.tf
locals {
  secrets = yamldecode(data.sops_file.postgres_secrets.raw)
}

resource "kubernetes_secret" "postgres_secrets" {
  metadata {
    name      = "postgres-secrets"
    namespace = kubernetes_namespace.paperless.metadata[0].name
  }

  type = "Opaque"

  data = {
    postgres-password = base64encode(local.secrets.postgres_password)
  }
}

resource "kubernetes_config_map" "postgres_config" {
  metadata {
    name      = "postgres-config"
    namespace = kubernetes_namespace.paperless.metadata[0].name
  }

  data = {
    POSTGRES_DB   = "paperless"
    POSTGRES_USER = "paperless"
  }
}