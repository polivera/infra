// ----- Postgres Configuration ------------------------------------------------
resource "kubernetes_persistent_volume" "postgres" {
  metadata {
    name = "paperless-postgres-pv"
  }
  spec {
    capacity = {
      storage = var.postgres.storage.size
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.postgres.storage.class

    persistent_volume_source {
      nfs {
        server = var.postgres.storage.ip
        path   = var.postgres.storage.path
      }
    }

    persistent_volume_reclaim_policy = "Retain"
  }
}

resource "kubernetes_persistent_volume_claim" "postgres" {
  metadata {
    name      = "postgres-storage"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.postgres.storage.class
    volume_name        = kubernetes_persistent_volume.postgres.metadata[0].name

    resources {
      requests = {
        storage = var.postgres.storage.size
      }
    }
  }
}
// -----------------------------------------------------------------------------

// ----- Redis Configuration ---------------------------------------------------
resource "kubernetes_persistent_volume" "redis" {
  metadata {
    name = "paperless-redis-pv"
  }
  spec {
    capacity = {
      storage = var.redis.storage.size
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.redis.storage.class
    persistent_volume_source {
      nfs {
        server = var.redis.storage.ip
        path   = var.redis.storage.path
      }
    }
    persistent_volume_reclaim_policy = "Retain"
  }
}

resource "kubernetes_persistent_volume_claim" "redis" {
  metadata {
    name      = "redis-storage"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.redis.storage.class
    volume_name        = kubernetes_persistent_volume.redis.metadata[0].name
    resources {
      requests = {
        storage = var.redis.storage.size
      }
    }
  }
}
// -----------------------------------------------------------------------------

// ----- Paperless Configuration -----------------------------------------------
// -- DATA --
resource "kubernetes_persistent_volume" "paperless_data" {
  metadata {
    name = "paperless-paperless-data-pv"
  }
  spec {
    capacity = {
      storage = var.paperless.storage.data.size
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.paperless.storage.data.class
    persistent_volume_source {
      nfs {
        server = var.paperless.storage.nfs-ip
        path   = var.paperless.storage.data.nfs-path
      }
    }
    persistent_volume_reclaim_policy = "Retain"
  }
}

resource "kubernetes_persistent_volume_claim" "paperless_data" {
  metadata {
    name      = "paperless-data-storage"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.paperless.storage.data.class
    volume_name        = kubernetes_persistent_volume.paperless_data.metadata[0].name
    resources {
      requests = {
        storage = var.paperless.storage.data.size
      }
    }
  }
}

// -- MEDIA --
resource "kubernetes_persistent_volume" "paperless_media" {
  metadata {
    name = "paperless-paperless-media-pv"
  }
  spec {
    capacity = {
      storage = var.paperless.storage.media.size
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.paperless.storage.media.class
    persistent_volume_source {
      nfs {
        server = var.paperless.storage.nfs-ip
        path   = var.paperless.storage.media.nfs-path
      }
    }
    persistent_volume_reclaim_policy = "Retain"
  }
}

resource "kubernetes_persistent_volume_claim" "paperless_media" {
  metadata {
    name      = "paperless-media-storage"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.paperless.storage.media.class
    volume_name        = kubernetes_persistent_volume.paperless_media.metadata[0].name
    resources {
      requests = {
        storage = var.paperless.storage.media.size
      }
    }
  }
}
