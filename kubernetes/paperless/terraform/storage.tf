# NFS Storage Classes
resource "kubernetes_storage_class" "nfs_fast" {
  metadata {
    name = "nfs-fast"
  }
  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "kubernetes_storage_class" "nfs_slow" {
  metadata {
    name = "nfs-slow"
  }
  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "WaitForFirstConsumer"
}

# PostgreSQL PV (using FastPool for database performance)
resource "kubernetes_persistent_volume" "postgres" {
  metadata {
    name = "paperless-postgres-pv"
  }
  spec {
    capacity = {
      storage = var.postgres.storage
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.nfs_fast.metadata[0].name

    persistent_volume_source {
      nfs {
        server = var.postgres.nfs-ip
        path   = var.postgres.nfs-path
      }
    }

    persistent_volume_reclaim_policy = "Retain"
  }
}

# PostgreSQL PVC
resource "kubernetes_persistent_volume_claim" "postgres" {
  metadata {
    name      = "postgres-storage"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.nfs_fast.metadata[0].name
    volume_name = kubernetes_persistent_volume.postgres.metadata[0].name

    resources {
      requests = {
        storage = var.postgres.storage
      }
    }
  }
}