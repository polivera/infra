# Service for Web UI (LoadBalancer with MetalLB)
resource "kubernetes_service" "adguard_dns_lb" {
  metadata {
    name      = "adguard-dns-lb"
    namespace = var.namespace
    labels = {
      app = "adguard"
    }
    annotations = {
      "metallb.universe.tf/address-pool" = var.metallb_pool
    }
  }

  spec {
    port {
      name = var.resources.service.dns.tcp
      port = 53
      target_port = 53
      protocol = "TCP"
    }
    port {
      name = var.resources.service.dns.udp
      port = 53
      target_port = 53
      protocol = "UDP"
    }

    type             = "LoadBalancer"
    load_balancer_ip = var.dns_load_balancer_ip
  }
}