# terraform/nfs-storage.tf

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

# Fast storage PV for PostgreSQL
resource "kubernetes_persistent_volume" "postgres_pv" {
  metadata {
    name = "paperless-postgres-pv"
  }

  spec {
    capacity = {
      storage = var.postgres_storage_size
    }

    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.nfs_fast.metadata[0].name

    persistent_volume_source {
      nfs {
        server = "192.168.0.11"
        path   = "/mnt/FastPool/paperless/postgres"
      }
    }

    persistent_volume_reclaim_policy = "Retain"
  }
}

# Fast storage PVC for PostgreSQL
resource "kubernetes_persistent_volume_claim" "postgres_pvc" {
  metadata {
    name      = "postgres-storage"
    namespace = kubernetes_namespace.paperless.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.nfs_fast.metadata[0].name
    volume_name = kubernetes_persistent_volume.postgres_pv.metadata[0].name

    resources {
      requests = {
        storage = var.postgres_storage_size
      }
    }
  }
}