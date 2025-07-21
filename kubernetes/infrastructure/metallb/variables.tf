variable "kube_config" {
  description = "Kubernetes config file"
  type = string
  default = "~/.kube/config"
}

variable "namespace" {
  description = "Namespace for MetalLB"
  type = string
  default = "metallb-system"
}