# modules/paperless/variables.tf
variable "namespace" {
  description = "Kubernetes namespace for Paperless"
  type        = string
  default     = "paperless"
}

variable "paperless_url" {
  description = "External URL for Paperless"
  type        = string
}

variable "secrets_file_path" {
  description = "Path to the encrypted secrets file"
  type        = string
}

# Storage variables
variable "postgres_storage_size" {
  description = "PostgreSQL storage size"
  type        = string
  default     = "1Gi"
}

variable "redis_storage_size" {
  description = "Redis storage size"
  type        = string
  default     = "512Mi"
}

variable "paperless_storage_size" {
  description = "Paperless storage size"
  type        = string
  default     = "10Gi"
}

variable "longhorn_ssd_storage_class" {
  description = "Longhorn SSD storage class name"
  type        = string
  default     = "longhorn-ssd"
}

variable "longhorn_hdd_storage_class" {
  description = "Longhorn HDD storage class name"
  type        = string
  default     = "longhorn-hdd"
}

# Image variables
variable "postgres_image" {
  description = "PostgreSQL Docker image"
  type        = string
  default     = "postgres:17"
}

variable "redis_image" {
  description = "Redis Docker image"
  type        = string
  default     = "redis:7"
}

variable "paperless_image" {
  description = "Paperless Docker image"
  type        = string
  default     = "ghcr.io/paperless-ngx/paperless-ngx:latest"
}

# Resource variables
variable "postgres_resources" {
  description = "PostgreSQL resource requests and limits"
  type = object({
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

variable "redis_resources" {
  description = "Redis resource requests and limits"
  type = object({
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

variable "paperless_resources" {
  description = "Paperless resource requests and limits"
  type = object({
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

# Configuration variables
variable "paperless_config" {
  description = "Additional Paperless configuration"
  type = object({
    time_zone                    = string
    ocr_language                = string
    ocr_languages               = string
    consumer_polling            = string
    consumer_delete_duplicates  = string
    consumer_recursive          = string
    consumer_subdirs_as_tags    = string
  })
  default = {
    time_zone                   = "Europe/Madrid"
    ocr_language               = "spa"
    ocr_languages              = "eng"
    consumer_polling           = "0"
    consumer_delete_duplicates = "true"
    consumer_recursive         = "true"
    consumer_subdirs_as_tags   = "true"
  }
}

variable "labels" {
  description = "Additional labels to apply to all resources"
  type        = map(string)
  default     = {}
}