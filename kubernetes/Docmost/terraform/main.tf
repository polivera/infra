# kubernetes/docmost/terraform/main.tf
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.1.1"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

data "sops_file" "secrets" {
  source_file = var.sops_file
}

# Create namespace
resource "kubernetes_namespace" "docmost" {
  metadata {
    name = var.namespace
  }
}
