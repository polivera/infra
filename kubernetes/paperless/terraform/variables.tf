// ----- Main config values ----------------------------------------------------
variable "kube_config" {
  description = "Kubernetes config file to use"
  type        = string
  default     = "~/.kube/config"
}

variable "sops_file" {
  description = "SOPS secrets file path"
  type        = string
  default     = "../secrets.enc.yaml"
}

variable "namespace" {
  description = "Kubernetes namespace for paperless stack"
  type        = string
  default     = "paperless"
}


// -----------------------------------------------------------------------------

variable "postgres" {
  description = "PostgreSQL configuration data"
  type = object({
    image   = string,
    storage = string,
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
    image   = "postgres:17"
    storage = "1Gi"
    requests = {
      memory = "256Mi"
      cpu    = "200m"
    }
    limits = {
      memory = "512Mi"
      cpu    = "500m"
    }
  }
}