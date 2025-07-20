terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}