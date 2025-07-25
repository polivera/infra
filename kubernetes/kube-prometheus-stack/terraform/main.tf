# kubernetes/prometheus/terraform/main.tf
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
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

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

data "sops_file" "secrets" {
  source_file = var.sops_file
}

# Create monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}