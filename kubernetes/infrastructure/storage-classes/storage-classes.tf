# NFS Storage Classes
resource "kubernetes_storage_class" "nfs_fast" {
  metadata {
    name = "nfs-fast"
  }
  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "kubernetes_storage_class" "nfs_slow" {
  metadata {
    name = "nfs-slow"
  }
  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "WaitForFirstConsumer"
}