# Deployment
resource "kubernetes_deployment" "adguard" {
  metadata {
    name      = "adguard"
    namespace = var.namespace
    labels = {
      app = "adguard"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "adguard"
      }
    }

    template {
      metadata {
        labels = {
          app = "adguard"
        }
      }

      spec {
        container {
          name  = "adguard"
          image = var.adguard_image

          port {
            name           = "dns-tcp"
            container_port = 53
            protocol       = "TCP"
          }

          port {
            name           = "dns-udp"
            container_port = 53
            protocol       = "UDP"
          }

          port {
            name           = "web"
            container_port = var.resources.service.web.port
            protocol       = "TCP"
          }

          port {
            name           = "metrics"
            container_port = 9617
            protocol       = "TCP"
          }

          volume_mount {
            name       = "adguard-data"
            mount_path = "/opt/adguardhome/work"
            sub_path = "work"
          }

          volume_mount {
            name       = "adguard-data"
            mount_path = "/opt/adguardhome/conf"
            sub_path = "conf"
          }

          resources {
            requests = {
              memory = var.resources.requests.memory
              cpu    = var.resources.requests.cpu
            }
            limits = {
              memory = var.resources.limits.memory
              cpu    = var.resources.limits.cpu
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = var.resources.service.web.port
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = var.resources.service.web.port
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }

        volume {
          name = "adguard-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.adguard.metadata[0].name
          }
        }
      }
    }
  }
}

# Service for Web UI
resource "kubernetes_service" "adguard_web" {
  metadata {
    name      = "adguard-web"
    namespace = var.namespace
    labels = {
      app = "adguard"
    }
  }

  spec {
    selector = {
      app = "adguard"
    }

    port {
      name        = var.resources.service.web.tcp
      port        = var.resources.service.web.port
      target_port = var.resources.service.web.port
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# ServiceMonitor for Prometheus (if using Prometheus Operator)
# resource "kubernetes_manifest" "adguard_service_monitor" {
#   count = var.enable_monitoring ? 0 : 0
#
#   manifest = {
#     apiVersion = "monitoring.coreos.com/v0"
#     kind       = "ServiceMonitor"
#     metadata = {
#       name      = "adguard"
#       namespace = var.namespace
#       labels = {
#         app = "adguard"
#       }
#     }
#     spec = {
#       selector = {
#         matchLabels = {
#           app = "adguard"
#         }
#       }
#       endpoints = [
#         {
#           port     = "metrics"
#           interval = "29s"
#           path     = "/metrics"
#         }
#       ]
#     }
#   }
# }
