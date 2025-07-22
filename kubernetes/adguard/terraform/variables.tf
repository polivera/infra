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
  default     = "192.168.0.100"
}

variable "metallb_pool" {
  description = "MetalLB address pool name"
  type        = string
  default     = "default-pool"
}

variable "enable_monitoring" {
  description = "Enable Prometheus monitoring"
  type        = bool
  default     = true
}

variable "resources" {
  description = "Resource requests and limits"
  type = object({
    pod = string
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
    service = object({
      dns = object({
        tcp = string
        udp = string
      })
      web = object({
        tcp = string
        port = string
      })
    })
  })
  default = {
    pod = "adguard"
    storage = {
      size  = "1Gi"
      ip    = "192.168.0.11"
      path  = "/mnt/FastPool/AdGuard/data"
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
    service = {
      dns = {
        tcp = "dns-tcp"
        udp = "dns-udp"
      }
      web = {
        tcp = "web-tcp"
        port = "3000"
      }
    }
  }
}