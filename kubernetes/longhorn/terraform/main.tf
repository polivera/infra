provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "kubectl" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

# Create longhorn-system namespace
resource "kubernetes_namespace" "longhorn_system" {
  metadata {
    name = "longhorn-system"
  }
}

# Install Longhorn using Helm
resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = "1.7.2"
  namespace  = kubernetes_namespace.longhorn_system.metadata[0].name

  set {
    name  = "defaultSettings.defaultDataPath"
    value = var.default_data_path
  }

  set {
    name  = "defaultSettings.replicaSoftAntiAffinity"
    value = var.replica_soft_anti_affinity
  }

  set {
    name  = "defaultSettings.defaultReplicaCount"
    value = var.replica_count
  }

  set {
    name  = "persistence.defaultClass"
    value = var.default_storage_class
  }

  depends_on = [kubernetes_namespace.longhorn_system]
}