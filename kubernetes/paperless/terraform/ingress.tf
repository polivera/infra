resource "kubernetes_ingress_v1" "paperless_ingress" {
  metadata {
    name      = "paperless-ingress"
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
              name = kubernetes_service.paperless.metadata[0].name
              port {
                number = 8000 # replace to a variable
              }
            }
          }
        }
      }
    }
  }
}