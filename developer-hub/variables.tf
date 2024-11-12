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

variable "github-org" {
  type    = string
  default = "piomin"
}

variable "github-token" {
  type    = string
  default = ""
}

variable "github-client-id" {
  type    = string
  default = "Iv23li3IorfilpLSHAan"
}

variable "argocd-token" {
  type    = string
  default = ""
}

variable "openshift-token" {
  type    = string
  default = ""
}

variable "github-client-secret" {
  type    = string
  default = ""
}

variable "azure-token" {
  type    = string
  default = ""
}

variable "azure-org" {
  type    = string
  default = "pminkows"
}

variable "domain" {
  type    = string
  default = "piomin.eastus.aroapp.io"
}