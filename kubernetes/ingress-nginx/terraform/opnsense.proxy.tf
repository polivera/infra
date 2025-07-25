locals {
  opnsense = {
    namespace    = var.external_service_namespace
    service_name = "opnsense-app"
    ingress_name = "opnsense-app-ingress"
    local_port   = 8080
    target_ip    = "192.168.0.1"
    target_port  = 8080
    hostname     = "opnsense.vicugna.party"
  }
}

resource "kubernetes_service" "external_service_opnsense" {
  metadata {
    name      = local.opnsense.service_name
    namespace = local.opnsense.namespace
  }

  spec {
    # No selector = external service
    port {
      name        = "http"
      port        = local.opnsense.local_port
      target_port = local.opnsense.target_port
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# Define the external endpoint
resource "kubernetes_endpoints" "external_service_opnsense" {
  metadata {
    name      = local.opnsense.service_name
    namespace = local.opnsense.namespace
  }

  subset {
    address {
      ip = local.opnsense.target_ip
    }

    port {
      name     = "http"
      port     = local.opnsense.target_port
      protocol = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "external_ingress_opnsense" {
  metadata {
    name = local.opnsense.ingress_name
    namespace = local.opnsense.namespace
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = local.opnsense.hostname

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = local.opnsense.service_name
              port {
                number = local.opnsense.local_port
              }
            }
          }
        }
      }
    }
  }
}