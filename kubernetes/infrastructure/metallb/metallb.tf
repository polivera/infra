# MetalLB Namespace
resource "kubernetes_namespace" "metallb_system" {
  metadata {
    name = "metallb-system"
  }
}

# MetalLB Installation via Helm
resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.14.8"
  namespace  = kubernetes_namespace.metallb_system.metadata[0].name

  # Wait for CRDs to be ready
  wait          = true
  wait_for_jobs = true
  timeout       = 600

  depends_on = [kubernetes_namespace.metallb_system]
}

# MetalLB IP Address Pool
resource "kubernetes_manifest" "metallb_ip_pool" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "default-pool"
      namespace = "metallb-system"
    }
    spec = {
      addresses = [
        "192.168.1.50-192.168.1.150"  # Adjust this range for your network
      ]
    }
  }

  # Add wait condition for CRDs
  wait = {
    fields = {
      "status.ready" = "true"
    }
  }

  depends_on = [helm_release.metallb]
}

# MetalLB L2Advertisement
resource "kubernetes_manifest" "metallb_l2_advertisement" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    metadata = {
      name      = "default-advertisement"
      namespace = "metallb-system"
    }
    spec = {
      ipAddressPools = ["default-pool"]
    }
  }

  # Add wait condition
  wait = {
    fields = {
      "status.ready" = "true"
    }
  }

  depends_on = [kubernetes_manifest.metallb_ip_pool]
}