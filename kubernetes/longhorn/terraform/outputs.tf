output "longhorn_namespace" {
  description = "Longhorn system namespace"
  value       = kubernetes_namespace.longhorn_system.metadata[0].name
}

output "longhorn_hdd_storage_class" {
  description = "Longhorn HDD storage class name"
  value       = kubernetes_storage_class.longhorn_hdd.metadata[0].name
}

output "longhorn_ssd_storage_class" {
  description = "Longhorn SSD storage class name"
  value       = kubernetes_storage_class.longhorn_ssd.metadata[0].name
}