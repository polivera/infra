locals {
  proxmox = {
    namespace    = var.external_service_namespace
    service_name = "proxmox-app"
    ingress_name = "proxmox-app-ingress"
    local_port   = 8006
    target_ip    = "192.168.0.10"
    target_port  = 8006
    hostname     = "proxmox.vicugna.party"
  }
}

resource "kubernetes_service" "external_service_proxmox" {
  metadata {
    name      = local.proxmox.service_name
    namespace = local.proxmox.namespace
  }

  spec {
    # No selector = external service
    port {
      name        = "http"
      port        = local.proxmox.local_port
      target_port = local.proxmox.target_port
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# Define the external endpoint
resource "kubernetes_endpoints" "external_service_proxmox" {
  metadata {
    name      = local.proxmox.service_name
    namespace = local.proxmox.namespace
  }

  subset {
    address {
      ip = local.proxmox.target_ip
    }

    port {
      name     = "http"
      port     = local.proxmox.target_port
      protocol = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "external_ingress_proxmox" {
  metadata {
    name = local.proxmox.ingress_name
    namespace = local.proxmox.namespace
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
      "nginx.ingress.kubernetes.io/proxy-ssl-verify" = "false"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = local.proxmox.hostname

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = local.proxmox.service_name
              port {
                number = local.proxmox.local_port
              }
            }
          }
        }
      }
    }
  }
}