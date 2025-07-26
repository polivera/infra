# kubernetes/docmost/terraform/redis.tf
# Config
resource "kubernetes_config_map" "redis" {
  metadata {
    name      = "redis-config"
    namespace = var.namespace
  }
  data = {
    REDIS_URL = "redis://redis:6379"
  }
}

# Redis Deployment
resource "kubernetes_deployment" "redis" {
  metadata {
    name      = "redis"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        container {
          name  = "redis"
          image = var.redis.image

          args = [
            "redis-server",
            "--save", "60", "1",
            "--loglevel", "warning"
          ]

          port {
            container_port = 6379
          }

          volume_mount {
            name       = "redis-data"
            mount_path = "/data"
          }

          resources {
            requests = {
              memory = var.redis.requests.memory
              cpu    = var.redis.requests.cpu
            }
            limits = {
              memory = var.redis.limits.memory
              cpu    = var.redis.limits.cpu
            }
          }

          liveness_probe {
            exec {
              command = ["redis-cli", "ping"]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            exec {
              command = ["redis-cli", "ping"]
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }

        volume {
          name = "redis-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.redis.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubernetes_persistent_volume_claim.redis]
}

# Redis Service
resource "kubernetes_service" "redis" {
  metadata {
    name      = "redis"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "redis"
    }

    port {
      port        = 6379
      target_port = 6379
    }
  }
}
