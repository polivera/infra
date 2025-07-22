# Paperless LoadBalancer Service
# resource "kubernetes_service" "paperless_lb" {
#   metadata {
#     name      = "paperless-lb"
#     namespace = var.namespace
#   }
#
#   spec {
#     selector = {
#       app = "paperless"
#     }
#
#     port {
#       port        = 80    # External port
#       target_port = 8000  # Paperless container port
#       protocol    = "TCP"
#     }
#
#     type = "LoadBalancer"
#   }
# }