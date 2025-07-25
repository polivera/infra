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

variable "hostname" {
  description = "Application hostname"
  type = string
  default = "paperless.vicugna.party"
}


// -----------------------------------------------------------------------------

// ----- Postgres Configuration ------------------------------------------------
variable "postgres" {
  description = "PostgreSQL configuration data"
  type = object({
    image = string,
    storage = object({
      size  = string
      ip    = string
      path  = string
      class = string
    }),
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
    image = "postgres:17"
    storage = {
      size  = "10Gi"
      ip    = "192.168.0.11"
      path  = "/mnt/FastPool/Paperless/postgres"
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
// -----------------------------------------------------------------------------

// ----- Redis Configuration ---------------------------------------------------
variable "redis" {
  description = "Redis configuration data"
  type = object({
    image    = string,
    storage  = string,
    storage = object({
      size  = string
      ip    = string
      path  = string
      class = string
    }),
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
    image    = "redis:7"
    storage = {
      size  = "1Gi"
      ip    = "192.168.0.11"
      path  = "/mnt/FastPool/Paperless/redis"
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
// -----------------------------------------------------------------------------

// ----- Redis Configuration ---------------------------------------------------
variable "paperless" {
  description = "Paperless configuration data"
  type = object({
    image = string,
    storage = object({
      nfs-ip = string
      data = object({
        size     = string,
        nfs-path = string
        class = string
      })
      media = object({
        size     = string,
        nfs-path = string
        class = string
      })
    }),
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
    image = "ghcr.io/paperless-ngx/paperless-ngx:latest"
    storage = {
      nfs-ip = "192.168.0.11"
      data = {
        size     = "50Gi"
        nfs-path = "/mnt/SlowPool/Paperless/data"
        class = "nfs-slow"
      }
      media = {
        size     = "100Gi"
        nfs-path = "/mnt/SlowPool/Paperless/media"
        class = "nfs-slow"
      }
    }
    requests = {
      memory = "512Mi"
      cpu    = "300m"
    }
    limits = {
      memory = "2Gi"
      cpu    = "1000m"
    }
  }
}
