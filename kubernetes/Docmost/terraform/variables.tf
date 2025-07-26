# kubernetes/docmost/terraform/variables.tf
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
  description = "Kubernetes namespace for docmost"
  type        = string
  default     = "docmost"
}

variable "hostname" {
  description = "Hostname for docmost"
  type        = string
  default     = "docs.vicugna.party"
}

variable "postgres" {
  description = "PostgreSQL configuration"
  type = object({
    image = string
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
    image = "postgres:16"
    storage = {
      size  = "10Gi"
      ip    = "192.168.0.11"
      path  = "/mnt/FastPool/Docmost/postgres"
      class = "nfs-fast"
    }
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

variable "redis" {
  description = "Redis configuration"
  type = object({
    image = string
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
    image = "redis:7"
    storage = {
      size  = "1Gi"
      ip    = "192.168.0.11"
      path  = "/mnt/FastPool/Docmost/redis"
      class = "nfs-fast"
    }
    requests = {
      memory = "128Mi"
      cpu    = "100m"
    }
    limits = {
      memory = "256Mi"
      cpu    = "200m"
    }
  }
}

variable "docmost" {
  description = "Docmost configuration"
  type = object({
    image = string
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
    image = "docmost/docmost:latest"
    storage = {
      size  = "20Gi"
      ip    = "192.168.0.11"
      path  = "/mnt/SlowPool/Docmost/data"
      class = "nfs-slow"
    }
    requests = {
      memory = "512Mi"
      cpu    = "300m"
    }
    limits = {
      memory = "1Gi"
      cpu    = "500m"
    }
  }
}
