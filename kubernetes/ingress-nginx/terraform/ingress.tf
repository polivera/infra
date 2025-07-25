

# Create namespace for ingress controller
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = var.namespace
  }
}

# Create the namespace
resource "kubernetes_namespace" "external_services" {
  metadata {
    name = var.external_service_namespace
  }
}

# Install NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.8.3"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name

  # Configure for MetalLB LoadBalancer
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = var.ingress_load_balancer_ip
  }

  set {
    name  = "controller.service.annotations.metallb\\.universe\\.tf/address-pool"
    value = var.metallb_pool
  }

  # Enable SSL redirect by default
  set {
    name  = "controller.config.ssl-redirect"
    value = var.resources.sslRedirect
  }

  # Configure for better performance
  set {
    name  = "controller.config.use-forwarded-headers"
    value = var.resources.forwardHeaders
  }

  set {
    name  = "controller.config.compute-full-forwarded-for"
    value = var.resources.fullForwardFor
  }

  # Resource limits
  set {
    name  = "controller.resources.requests.cpu"
    value = var.resources.requests.cpu
  }

  set {
    name  = "controller.resources.requests.memory"
    value = var.resources.requests.memory
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = var.resources.limits.cpu
  }

  set {
    name  = "controller.resources.limits.memory"
    value = var.resources.limits.memory
  }

  depends_on = [kubernetes_namespace.ingress_nginx]
}
