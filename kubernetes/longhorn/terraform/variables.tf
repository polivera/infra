variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/local.yaml"
}

variable "node_names" {
  description = "List of Kubernetes node names for Longhorn"
  type = list(string)
  default = ["minikube"]
}

variable "hdd_storage_path" {
  description = "Path for HDD storage on nodes"
  type        = string
  default     = "/tmp/longhorn/hdd"
}

variable "ssd_storage_path" {
  description = "Path for SSD storage on nodes"
  type        = string
  default     = "/tmp/longhorn/ssd"
}

variable "replica_count" {
  description = "Number of replicas for Longhorn volumes"
  type        = string
  default     = "1"
}

variable "stale_replica_timeout" {
  description = "Timeout for stale replicas in minutes"
  type        = string
  default     = "20"
}

variable "replica_soft_anti_affinity" {
  description = "Controls whether replicas avoid being placed on the same node"
  type        = string
  default     = "false"
}

variable "default_data_path" {
  description = "Sets where Longhorn stores its data on each node"
  type        = string
  default     = "/var/lib/longhorn/"
}

variable "default_storage_class" {
  description = "Prevents Longhorn from creating a default StorageClass"
  type        = string
  default     = "false"
}