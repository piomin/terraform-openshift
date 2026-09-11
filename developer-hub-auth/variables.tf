variable "cluster-context" {
  type    = string
  default = "system:admin"
}

variable "kubeconfig" {
  type    = string
  default = "~/.kube/config"
}

variable "keycloak-client-secret" {
  type    = string
  default = ""
}

variable "domain" {
  type    = string
  default = "piomin.eastus.aroapp.io"
}