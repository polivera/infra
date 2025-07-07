resource "kubernetes_storage_class" "longhorn_hdd" {
  metadata {
    name = "longhorn-hdd"
  }

  storage_provisioner    = "driver.longhorn.io"
  allow_volume_expansion = true
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"

  parameters = {
    numberOfReplicas    = var.replica_count
    diskSelector        = "hdd"
    dataLocality        = "disabled"
    staleReplicaTimeout = var.stale_replica_timeout
  }

  depends_on = [helm_release.longhorn]
}

resource "kubernetes_storage_class" "longhorn_ssd" {
  metadata {
    name = "longhorn-ssd"
  }

  storage_provisioner    = "driver.longhorn.io"
  allow_volume_expansion = true
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"

  parameters = {
    numberOfReplicas    = var.replica_count
    diskSelector        = "ssd"
    dataLocality        = "disabled"
    staleReplicaTimeout = var.stale_replica_timeout
  }

  depends_on = [helm_release.longhorn]
}