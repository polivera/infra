# kubernetes/docmost/terraform/config.tf

resource "kubernetes_config_map" "docmost" {
  metadata {
    name      = "docmost-config"
    namespace = var.namespace
  }
  data = {
    APP_URL      = "https://${var.hostname}"
    REDIS_URL    = "redis://redis:6379"
  }
}

# kubernetes/docmost/terraform/docmost.tf
# Docmost Deployment
resource "kubernetes_deployment" "docmost" {
  metadata {
    name      = "docmost"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "docmost"
      }
    }

    template {
      metadata {
        labels = {
          app = "docmost"
        }
      }

      spec {
        container {
          name  = "docmost"
          image = var.docmost.image

          env {
            name = "APP_URL"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.docmost.metadata[0].name
                key  = "APP_URL"
              }
            }
          }

          env {
            name = "APP_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.docmost.metadata[0].name
                key  = "app-secret"
              }
            }
          }

          env {
            name = "JWT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.docmost.metadata[0].name
                key  = "jwt-secret"
              }
            }
          }

          env {
            name = "DATABASE_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.docmost.metadata[0].name
                key = "database-url"
              }
            }
          }

          env {
            name = "REDIS_URL"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.redis.metadata[0].name
                key  = "REDIS_URL"
              }
            }
          }

          port {
            container_port = 3000
          }

          volume_mount {
            name       = "docmost-data"
            mount_path = "/app/data"
          }

          resources {
            requests = {
              memory = var.docmost.requests.memory
              cpu    = var.docmost.requests.cpu
            }
            limits = {
              memory = var.docmost.limits.memory
              cpu    = var.docmost.limits.cpu
            }
          }

          readiness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 60
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 120
            period_seconds        = 30
          }
        }

        volume {
          name = "docmost-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.docmost.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_deployment.redis,
    kubernetes_stateful_set.postgres,
    kubernetes_persistent_volume_claim.docmost
  ]
}

# Docmost Service
resource "kubernetes_service" "docmost" {
  metadata {
    name      = "docmost"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "docmost"
    }

    port {
      port        = 3000
      target_port = 3000
    }
  }
}

# kubernetes/docmost/terraform/ingress.tf
resource "kubernetes_ingress_v1" "docmost_ingress" {
  metadata {
    name      = "docmost-ingress"
    namespace = var.namespace
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.hostname

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.docmost.metadata[0].name
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}