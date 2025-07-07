variable "node_names" {
  description = "List of Kubernetes node names for Longhorn"
  type        = list(string)
  default     = ["nodea", "nodeb", "nodec"]
}

variable "hdd_storage_path" {
  description = "Path for HDD storage on nodes"
  type        = string
  default     = "/mnt/hdd-storage"
}

variable "ssd_storage_path" {
  description = "Path for SSD storage on nodes"
  type        = string
  default     = "/mnt/ssd-storage"
}

variable "replica_count" {
  description = "Number of replicas for Longhorn volumes"
  type        = string
  default     = "3"
}

variable "stale_replica_timeout" {
  description = "Timeout for stale replicas in minutes"
  type        = string
  default     = "20"
}