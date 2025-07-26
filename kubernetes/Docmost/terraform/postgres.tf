# kubernetes/docmost/terraform/postgres.tf
# Config
resource "kubernetes_config_map" "postgres" {
  metadata {
    name      = "postgres-config"
    namespace = var.namespace
  }
  data = {
    POSTGRES_DB   = "docmost"
    POSTGRES_USER = "docmost"
  }
}

# PostgreSQL StatefulSet
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
          image = var.postgres.image

          env {
            name = "POSTGRES_DB"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.postgres.metadata[0].name
                key  = "POSTGRES_DB"
              }
            }
          }

          env {
            name = "POSTGRES_USER"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.postgres.metadata[0].name
                key  = "POSTGRES_USER"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.docmost.metadata[0].name
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
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }

          resources {
            requests = {
              memory = var.postgres.requests.memory
              cpu    = var.postgres.requests.cpu
            }
            limits = {
              memory = var.postgres.limits.memory
              cpu    = var.postgres.limits.cpu
            }
          }

          liveness_probe {
            exec {
              command = [
                "sh",
                "-c",
                "pg_isready -U $POSTGRES_USER -d $POSTGRES_DB"
              ]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            exec {
              command = [
                "sh",
                "-c",
                "pg_isready -U $POSTGRES_USER -d $POSTGRES_DB"
              ]
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }

        volume {
          name = "postgres-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubernetes_persistent_volume_claim.postgres]
}

# PostgreSQL Services
resource "kubernetes_service" "postgres_headless" {
  metadata {
    name      = "postgres-headless"
    namespace = var.namespace
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
