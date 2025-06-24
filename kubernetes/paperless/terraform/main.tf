# terraform/main.tf
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Load encrypted secrets
data "sops_file" "postgres_secrets" {
  source_file = "../secrets.enc.yaml"
}
