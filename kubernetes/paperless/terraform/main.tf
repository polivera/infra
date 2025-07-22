terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.1.1"
    }
  }
}

provider "kubernetes" {
  config_path = var.kube_config
}

data "sops_file" "secrets" {
  source_file = var.sops_file
}

# Create namespace
resource "kubernetes_namespace" "paperless" {
  metadata {
    name = var.namespace
  }
}