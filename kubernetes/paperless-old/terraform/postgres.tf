# terraform/postgres.tf
resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "postgres"
    namespace = var.namespace
  }

  spec {
    service_name = "postgres-headless"
    replicas     = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = var.postgres_image

          env {
            name = "POSTGRES_DB"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.postgres_config.metadata[0].name
                key  = "POSTGRES_DB"
              }
            }
          }

          env {
            name = "POSTGRES_USER"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.postgres_config.metadata[0].name
                key  = "POSTGRES_USER"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_secrets.metadata[0].name
                key  = "postgres-password"
              }
            }
          }

          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }

          port {
            container_port = 5432
          }

          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
          }

          resources {
            requests = {
              memory = var.postgres_resources.requests.memory
              cpu    = var.postgres_resources.requests.cpu
            }
            limits = {
              memory = var.postgres_resources.limits.memory
              cpu    = var.postgres_resources.limits.cpu
            }
          }

          liveness_probe {
            exec {
              command = ["pg_isready", "-U", "paperless"]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            exec {
              command = ["pg_isready", "-U", "paperless"]
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "postgres-storage"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "1Gi"
          }
        }
        storage_class_name = "longhorn-ssd"
      }
    }
  }
}

# Headless service for StatefulSet
resource "kubernetes_service" "postgres_headless" {
  metadata {
    name      = "postgres-headless"
    namespace = kubernetes_namespace.paperless.metadata[0].name
  }

  spec {
    cluster_ip = "None"
    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}

# Regular service for easy access
resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}