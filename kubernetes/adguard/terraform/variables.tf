# terraform/adguard/variables.tf
variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "namespace" {
  description = "Kubernetes namespace for AdGuard"
  type        = string
  default     = "adguard"
}

variable "adguard_image" {
  description = "AdGuard Home Docker image"
  type        = string
  default     = "adguard/adguardhome:v0.107.61"
}

variable "dns_load_balancer_ip" {
  description = "IP address for DNS service (MetalLB)"
  type        = string
  default     = "192.168.0.50"
}

variable "web_load_balancer_ip" {
  description = "IP address for web interface (MetalLB)"
  type        = string
  default     = "192.168.0.54"
}

variable "metallb_pool" {
  description = "MetalLB address pool name"
  type        = string
  default     = "default"
}

variable "storage_class" {
  description = "Storage class for persistent volumes"
  type        = string
  default     = "nfs-fast"
}

variable "storage_size" {
  description = "Storage size for AdGuard data"
  type        = string
  default     = "1Gi"
}

variable "enable_monitoring" {
  description = "Enable Prometheus monitoring"
  type        = bool
  default     = true
}

variable "resources" {
  description = "Resource requests and limits"
  type = object({
    storage = object({
      size  = string
      ip    = string
      path  = string
      class = string
    })
    requests = object({
      memory = string
      cpu    = string
    })
    limits = object({
      memory = string
      cpu    = string
    })
  })
  default = {
    storage = {
      size  = "1Gi"
      ip    = "192.168.0.11"
      path  = "/mnt/FastPool/adguard"
      class = "nfs-fast"
    }
    requests = {
      memory = "128Mi"
      cpu    = "100m"
    }
    limits = {
      memory = "512Mi"
      cpu    = "500m"
    }
  }
}