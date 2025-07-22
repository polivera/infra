# ConfigMap for AdGuard configuration
resource "kubernetes_config_map" "adguard_config" {
  metadata {
    name      = "adguard-config"
    namespace = var.namespace
  }

  data = {
    "AdGuardHome.yaml" = templatefile("${path.module}/config/AdGuardHome.yaml.tpl", {
      bind_host = "0.0.0.0"
      bind_port = 3000
      dns_port  = 53
    })
  }
}

# PersistentVolumeClaim for AdGuard data
resource "kubernetes_persistent_volume_claim" "adguard_data" {
  metadata {
    name      = "adguard-data"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
    storage_class_name = var.storage_class
  }
}

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
            container_port = 3000
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
          }

          volume_mount {
            name       = "adguard-config"
            mount_path = "/opt/adguardhome/conf"
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
              port = 3000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }

        volume {
          name = "adguard-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.adguard_data.metadata[0].name
          }
        }

        volume {
          name = "adguard-config"
          config_map {
            name = kubernetes_config_map.adguard_config.metadata[0].name
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
      name        = "web"
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# Service for DNS (LoadBalancer with MetalLB)
resource "kubernetes_service" "adguard_dns" {
  metadata {
    name      = "adguard-dns"
    namespace = var.namespace
    labels = {
      app = "adguard"
    }
    annotations = {
      "metallb.universe.tf/address-pool" = var.metallb_pool
    }
  }

  spec {
    selector = {
      app = "adguard"
    }

    port {
      name        = "dns-tcp"
      port        = 53
      target_port = 53
      protocol    = "TCP"
    }

    port {
      name        = "dns-udp"
      port        = 53
      target_port = 53
      protocol    = "UDP"
    }

    type             = "LoadBalancer"
    load_balancer_ip = var.dns_load_balancer_ip
  }
}

# Service for Web UI (LoadBalancer with MetalLB)
resource "kubernetes_service" "adguard_web_lb" {
  metadata {
    name      = "adguard-web-lb"
    namespace = var.namespace
    labels = {
      app = "adguard"
    }
    annotations = {
      "metallb.universe.tf/address-pool" = var.metallb_pool
    }
  }

  spec {
    selector = {
      app = "adguard"
    }

    port {
      name        = "web"
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }

    type             = "LoadBalancer"
    load_balancer_ip = var.web_load_balancer_ip
  }
}

# ServiceMonitor for Prometheus (if using Prometheus Operator)
resource "kubernetes_manifest" "adguard_service_monitor" {
  count = var.enable_monitoring ? 1 : 0

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "adguard"
      namespace = var.namespace
      labels = {
        app = "adguard"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          app = "adguard"
        }
      }
      endpoints = [
        {
          port     = "metrics"
          interval = "30s"
          path     = "/metrics"
        }
      ]
    }
  }
}