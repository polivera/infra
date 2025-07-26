# kubernetes/docmost/terraform/storage.tf
# PostgreSQL Storage
resource "kubernetes_persistent_volume" "postgres" {
  metadata {
    name = "docmost-postgres-pv"
  }
  spec {
    capacity = {
      storage = var.postgres.storage.size
    }
    access_modes       = ["ReadWriteOnce"]
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
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.postgres.storage.class
    volume_name        = kubernetes_persistent_volume.postgres.metadata[0].name

    resources {
      requests = {
        storage = var.postgres.storage.size
      }
    }
  }
}

# Redis Storage
resource "kubernetes_persistent_volume" "redis" {
  metadata {
    name = "docmost-redis-pv"
  }
  spec {
    capacity = {
      storage = var.redis.storage.size
    }
    access_modes       = ["ReadWriteOnce"]
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
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.redis.storage.class
    volume_name        = kubernetes_persistent_volume.redis.metadata[0].name

    resources {
      requests = {
        storage = var.redis.storage.size
      }
    }
  }
}

# Docmost Storage
resource "kubernetes_persistent_volume" "docmost" {
  metadata {
    name = "docmost-data-pv"
  }
  spec {
    capacity = {
      storage = var.docmost.storage.size
    }
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.docmost.storage.class

    persistent_volume_source {
      nfs {
        server = var.docmost.storage.ip
        path   = var.docmost.storage.path
      }
    }

    persistent_volume_reclaim_policy = "Retain"
  }
}

resource "kubernetes_persistent_volume_claim" "docmost" {
  metadata {
    name      = "docmost-storage"
    namespace = var.namespace
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.docmost.storage.class
    volume_name        = kubernetes_persistent_volume.docmost.metadata[0].name

    resources {
      requests = {
        storage = var.docmost.storage.size
      }
    }
  }
}
