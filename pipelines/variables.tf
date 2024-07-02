variable "cluster-context" {
  type    = string
  default = "system:admin"
}

variable "kubeconfig" {
  type    = string
  default = "~/.kube/config"
}

variable "vault-addr" {
  type    = string
  default = "system:admin"
}