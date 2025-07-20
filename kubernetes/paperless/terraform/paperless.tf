# Paperless Deployment
resource "kubernetes_deployment" "paperless" {
  metadata {
    name      = "paperless"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "paperless"
      }
    }
    template {
      metadata {
        labels = {
          app = "paperless"
        }
      }
      spec {
        enable_service_links = false

        container {
          name  = "paperless"
          image = var.paperless.image

          env {
            name  = "PORT"
            value = "8000"
          }

          # Database configuration
          env {
            name = "PAPERLESS_DBHOST"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.postgres.metadata[0].name
                key  = "POSTGRES_DB_HOST"
              }
            }
          }
          env {
            name = "PAPERLESS_DBNAME"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.postgres.metadata[0].name
                key  = "POSTGRES_DB"
              }
            }
          }
          env {
            name = "PAPERLESS_DBUSER"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.postgres.metadata[0].name
                key  = "POSTGRES_USER"
              }
            }
          }
          env {
            name = "PAPERLESS_DBPASS"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres.metadata[0].name
                key  = "postgres-password"
              }
            }
          }
          # Redis configuration
          env {
            name = "PAPERLESS_REDIS"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.redis.metadata[0].name
                key  = "REDIS_HOST"
              }
            }
          }
          # Paperless secret key
          env {
            name = "PAPERLESS_SECRET_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres.metadata[0].name
                key  = "paperless-secret-key"
              }
            }
          }

          # Basic configuration
          env {
            name = "PAPERLESS_URL"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.paperless.metadata[0].name
                key  = "PAPERLESS_URL"
              }
            }
          }

          env {
            name = "PAPERLESS_TIME_ZONE"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.paperless.metadata[0].name
                key  = "PAPERLESS_TIME_ZONE"
              }
            }
          }

          env {
            name = "PAPERLESS_OCR_LANGUAGE"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.paperless.metadata[0].name
                key  = "PAPERLESS_OCR_LANGUAGE"
              }
            }
          }

          env {
            name = "PAPERLESS_OCR_LANGUAGES"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.paperless.metadata[0].name
                key  = "PAPERLESS_OCR_LANGUAGES"
              }
            }
          }

          # Consumer settings
          env {
            name = "PAPERLESS_CONSUMER_DISABLE"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.paperless.metadata[0].name
                key  = "PAPERLESS_CONSUMER_DISABLE"
              }
            }
          }

          # Security settings
          env {
            name = "PAPERLESS_ALLOWED_HOSTS"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.paperless.metadata[0].name
                key  = "PAPERLESS_ALLOWED_HOSTS"
              }
            }
          }

          env {
            name = "PAPERLESS_CSRF_TRUSTED_ORIGINS"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.paperless.metadata[0].name
                key  = "PAPERLESS_CSRF_TRUSTED_ORIGINS"
              }
            }
          }

          env {
            name = "PAPERLESS_FORCE_SCRIPT_NAME"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.paperless.metadata[0].name
                key  = "PAPERLESS_FORCE_SCRIPT_NAME"
              }
            }
          }

          env {
            name = "PAPERLESS_STATIC_URL"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.paperless.metadata[0].name
                key  = "PAPERLESS_STATIC_URL"
              }
            }
          }

          env {
            name = "PAPERLESS_USE_X_FORWARDED_HOST"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.paperless.metadata[0].name
                key  = "PAPERLESS_USE_X_FORWARDED_HOST"
              }
            }
          }

          env {
            name = "PAPERLESS_USE_X_FORWARDED_PORT"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.paperless.metadata[0].name
                key  = "PAPERLESS_USE_X_FORWARDED_PORT"
              }
            }
          }

          port {
            container_port = 8000
          }

          volume_mount {
            name       = "paperless-data"
            mount_path = "/usr/src/paperless/data"
          }

          volume_mount {
            name       = "paperless-media"
            mount_path = "/usr/src/paperless/media"
          }

          resources {
            requests = {
              memory = var.paperless.requests.memory
              cpu    = var.paperless.requests.cpu
            }
            limits = {
              memory = var.paperless.limits.memory
              cpu    = var.paperless.limits.cpu
            }
          }

          readiness_probe {
            http_get {
              path = "/"  # Better endpoint for readiness
              port = 8000
            }
            initial_delay_seconds = 60  # Give more time for Django to start
            period_seconds    = 10
            timeout_seconds   = 5
            failure_threshold = 3
          }

          liveness_probe {
            http_get {
              path = "/"  # Better than root path
              port = 8000
            }
            initial_delay_seconds = 120  # Give even more time for first startup
            period_seconds    = 30
            timeout_seconds   = 10
            failure_threshold = 3
          }
        }

        volume {
          name = "paperless-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.paperless_data.metadata[0].name
          }
        }

        volume {
          name = "paperless-media"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.paperless_media.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_deployment.redis,
    kubernetes_stateful_set.postgres,
    kubernetes_persistent_volume_claim.paperless_data,
    kubernetes_persistent_volume_claim.paperless_media,
  ]
}

# Paperless Service
resource "kubernetes_service" "paperless" {
  metadata {
    name      = "paperless"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "paperless"
    }

    port {
      port        = 8000
      target_port = 8000
    }

    type = "ClusterIP"
  }
}