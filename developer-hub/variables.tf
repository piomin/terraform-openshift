variable "cluster-context" {
  type    = string
  default = "system:admin"
}

variable "kubeconfig" {
  type    = string
  default = "~/.kube/config"
}

variable "sonar-token" {
  type    = string
  default = ""
}

variable "github-token" {
  type    = string
  default = ""
}

variable "github-client-id" {
  type    = string
  default = "Iv23livtfLgffsRQiXmV"
}

variable "argocd-token" {
  type    = string
  default = ""
}

variable "github-client-secret" {
  type    = string
  default = ""
}