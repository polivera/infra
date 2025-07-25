resource "kubernetes_ingress_v1" "adguard_ingress" {
  metadata {
    name      = "adguard-ingress"
    namespace = var.namespace
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
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
              name = kubernetes_service.adguard_web.metadata[0].name
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