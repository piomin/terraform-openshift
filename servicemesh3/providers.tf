terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.13.0"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig
  config_context = var.cluster-context
}

provider "kubectl" {
  config_path = var.kubeconfig
  config_context = var.cluster-context
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig
    config_context = var.cluster-context
  }
}