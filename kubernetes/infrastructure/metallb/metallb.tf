# MetalLB Namespace
resource "kubernetes_namespace" "metallb_system" {
  metadata {
    name = var.namespace
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


# ------------------------------------------------------------------------
# You have to execute this in two steps.
# First comment the code below this line and apply.
# After that uncomment the rest of the file
# ------------------------------------------------------------------------


# MetalLB IP Address Pool
resource "kubernetes_manifest" "metallb_ip_pool" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "default-pool"
      namespace = var.namespace
    }
    spec = {
      addresses = [
        "192.168.0.100-192.168.0.150"
      ]
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
      namespace = var.namespace
    }
    spec = {
      ipAddressPools = ["default-pool"]
    }
  }
  depends_on = [kubernetes_manifest.metallb_ip_pool]
}