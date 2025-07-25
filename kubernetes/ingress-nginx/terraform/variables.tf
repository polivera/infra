# terraform/adguard/variables.tf
variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "namespace" {
  description = "Kubernetes namespace for NGINX Ingress"
  type        = string
  default     = "ingress-nginx"
}

variable "external_service_namespace" {
  description = "Kubernetes namespace for external services"
  type        = string
  default     = "external-services"
}

variable "ingress_load_balancer_ip" {
  description = "IP address for DNS service (MetalLB)"
  type        = string
  default     = "192.168.0.101"
}

variable "metallb_pool" {
  description = "MetalLB address pool name"
  type        = string
  default     = "default-pool"
}

variable "resources" {
  description = "Resource requests and limits"
  type = object({
    sslRedirect = string
    forwardHeaders = string
    fullForwardFor = string
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
    sslRedirect = "true"
    forwardHeaders = "true"
    fullForwardFor = "trie"
    storage = {
      size  = "1Gi"
      ip    = "192.168.0.11"
      path  = "/mnt/FastPool/AdGuard/data"
      class = "nfs-fast"
    }
    requests = {
      memory = "90Mi"
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
        tcp  = "web-tcp"
        port = "3000"
      }
    }
  }
}