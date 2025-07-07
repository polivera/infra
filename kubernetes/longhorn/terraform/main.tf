provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "kubectl" {
  config_path = "~/.kube/config"
}

# Apply the main Longhorn installation
resource "kubectl_manifest" "longhorn_installation" {
  yaml_body = file("${path.module}/longhorn-installation.yaml")

  depends_on = [
    kubernetes_namespace.longhorn_system
  ]
}

# Create longhorn-system namespace first
resource "kubernetes_namespace" "longhorn_system" {
  metadata {
    name = "longhorn-system"
  }
}