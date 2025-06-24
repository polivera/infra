# terraform/namespace.tf
resource "kubernetes_namespace" "paperless" {
  metadata {
    name = "paperless"
  }
}