// ----- Adguard Storage Configuration -----------------------------------------
resource "kubernetes_persistent_volume" "adguard" {
  metadata {
    name = "adguard-adguard-pv"
  }
  spec {
    capacity = {
      storage = var.resources.storage.size
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.resources.storage.class

    persistent_volume_source {
      nfs {
        server = var.resources.storage.ip
        path   = var.resources.storage.path
      }
    }

    persistent_volume_reclaim_policy = "Retain"
  }
}

resource "kubernetes_persistent_volume_claim" "adguard" {
  metadata {
    name      = "adguard-storage"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.resources.storage.class
    volume_name        = kubernetes_persistent_volume.adguard.metadata[0].name

    resources {
      requests = {
        storage = var.resources.storage.size
      }
    }
  }
}
// -----------------------------------------------------------------------------