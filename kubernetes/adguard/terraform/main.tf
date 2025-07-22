# terraform/adguard/main.tf
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

# Create namespace
resource "kubernetes_namespace" "adguard" {
  metadata {
    name = var.namespace
  }
}