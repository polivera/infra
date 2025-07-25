# kubernetes/prometheus/terraform/storage.tf

# ----- Prometheus Storage Configuration ----------------------------------
resource "kubernetes_persistent_volume" "prometheus" {
  metadata {
    name = "prometheus-prometheus-pv"
  }
  spec {
    capacity = {
      storage = var.prometheus.storage.size
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.prometheus.storage.class

    persistent_volume_source {
      nfs {
        server = var.prometheus.storage.nfs_server
        path   = var.prometheus.storage.nfs_path
      }
    }

    persistent_volume_reclaim_policy = "Retain"
  }
}

# resource "kubernetes_persistent_volume_claim" "prometheus" {
#   metadata {
#     name      = "prometheus-prometheus-db-prometheus-kube-prometheus-prometheus-0"
#     namespace = var.namespace
#   }
#
#   spec {
#     access_modes = ["ReadWriteOnce"]
#     storage_class_name = var.prometheus.storage.class
#     volume_name        = kubernetes_persistent_volume.prometheus.metadata[0].name
#
#     resources {
#       requests = {
#         storage = var.prometheus.storage.size
#       }
#     }
#   }
# }

# ----- Grafana Storage Configuration -------------------------------------
resource "kubernetes_persistent_volume" "grafana" {
  metadata {
    name = "grafana-pv"
  }
  spec {
    capacity = {
      storage = var.grafana.storage.size
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.grafana.storage.class

    persistent_volume_source {
      nfs {
        server = var.grafana.storage.nfs_server
        path   = var.grafana.storage.nfs_path
      }
    }

    persistent_volume_reclaim_policy = "Retain"
  }
}

# resource "kubernetes_persistent_volume_claim" "grafana" {
#   metadata {
#     name      = "prometheus-grafana"
#     namespace = var.namespace
#   }
#
#   spec {
#     access_modes = ["ReadWriteOnce"]
#     storage_class_name = var.grafana.storage.class
#     volume_name        = kubernetes_persistent_volume.grafana.metadata[0].name
#
#     resources {
#       requests = {
#         storage = var.grafana.storage.size
#       }
#     }
#   }
# }

# ----- AlertManager Storage Configuration --------------------------------
resource "kubernetes_persistent_volume" "alertmanager" {
  metadata {
    name = "prometheus-alertmanager-pv"
  }
  spec {
    capacity = {
      storage = var.alertmanager.storage.size
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.alertmanager.storage.class

    persistent_volume_source {
      nfs {
        server = var.alertmanager.storage.nfs_server
        path   = var.alertmanager.storage.nfs_path
      }
    }

    persistent_volume_reclaim_policy = "Retain"
  }
}

# resource "kubernetes_persistent_volume_claim" "alertmanager" {
#   metadata {
#     name      = "alertmanager-prometheus-kube-prometheus-alertmanager-db-alertmanager-prometheus-kube-prometheus-alertmanager-0"
#     namespace = var.namespace
#   }
#
#   spec {
#     access_modes = ["ReadWriteOnce"]
#     storage_class_name = var.alertmanager.storage.class
#     volume_name        = kubernetes_persistent_volume.alertmanager.metadata[0].name
#
#     resources {
#       requests = {
#         storage = var.alertmanager.storage.size
#       }
#     }
#   }
# }