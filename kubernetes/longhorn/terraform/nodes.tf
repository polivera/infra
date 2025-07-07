resource "kubectl_manifest" "longhorn_nodes" {
  for_each = toset(var.node_names)

  yaml_body = yamlencode({
    apiVersion = "longhorn.io/v1beta2"
    kind       = "Node"
    metadata = {
      name      = each.value
      namespace = "longhorn-system"
    }
    spec = {
      disks = {
        hdd-disk = {
          allowScheduling   = true
          evictionRequested = false
          path             = var.hdd_storage_path
          tags             = ["hdd"]
        }
        ssd-disk = {
          allowScheduling   = true
          evictionRequested = false
          path             = var.ssd_storage_path
          tags             = ["ssd"]
        }
      }
    }
  })

  depends_on = [kubectl_manifest.longhorn_installation]
}