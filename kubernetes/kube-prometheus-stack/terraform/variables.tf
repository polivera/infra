# kubernetes/prometheus/terraform/variables.tf
variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "sops_file" {
  description = "SOPS secrets file path"
  type        = string
  default     = "../secrets.enc.yaml"
}

variable "namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "prometheus" {
  description = "Prometheus configuration"
  type = object({
    retention      = string
    retention_size = string
    storage = object({
      class      = string
      size       = string
      nfs_server = string
      nfs_path   = string
    })
  })
  default = {
    retention      = "30d"
    retention_size = "15GB"
    storage = {
      class      = "nfs-fast"
      size       = "20Gi"
      nfs_server = "192.168.0.11"
      nfs_path   = "/mnt/FastPool/Monitoring/prometheus"
    }
  }
}

variable "grafana" {
  description = "Grafana configuration"
  type = object({
    hostname       = string
    storage = object({
      class      = string
      size       = string
      nfs_server = string
      nfs_path   = string
    })
  })
  default = {
    hostname       = "grafana.vicugna.party"
    storage = {
      class      = "nfs-fast"
      size       = "5Gi"
      nfs_server = "192.168.0.11"
      nfs_path   = "/mnt/FastPool/Monitoring/grafana"
    }
  }
}

variable "alertmanager" {
  description = "AlertManager configuration"
  type = object({
    storage = object({
      class      = string
      size       = string
      nfs_server = string
      nfs_path   = string
    })
  })
  default = {
    storage = {
      class      = "nfs-fast"
      size       = "2Gi"
      nfs_server = "192.168.0.11"
      nfs_path   = "/mnt/FastPool/Monitoring/alertmanager"
    }
  }
}