variable "cluster-context" {
  type    = string
  default = "system:admin"
}

variable "domain" {
  type    = string
  default = "apps.qdrzhgxyxy.eastus.aroapp.io"
}

variable "kubeconfig" {
  type    = string
  default = "~/.kube/config"
}