locals {
  secrets = yamldecode(data.sops_file.secrets.raw)
}

resource "kubernetes_secret" "grafana" {
  metadata {
    name      = "grafana-secrets"
    namespace = var.namespace
  }
  type = "Opaque"
  data = {
    grafana-admin-user = base64encode(local.secrets.grafana_admin_user)
    grafana-admin-password = base64encode(local.secrets.grafana_admin_password)
  }
}