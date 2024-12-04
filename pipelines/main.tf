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
  config_path = "~/.kube/config"
  config_context = var.cluster-context
}

provider "kubectl" {
  config_path = var.kubeconfig
  config_context = var.cluster-context
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = var.cluster-context
  }
}

provider "vault" {
  token = "root"
  address = var.vault-addr
}

resource "kubernetes_manifest" "pipelines-subscription" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata" = {
      "name"      = "openshift-pipelines-operator-rh"
      "namespace" = "openshift-operators"
    }
    "spec" = {
      "channel"             = "latest"
      "installPlanApproval" = "Automatic"
      "name"                = "openshift-pipelines-operator-rh"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}

resource "kubernetes_namespace" "acs" {
  metadata {
    name = "rhacs-operator"
  }
}

resource "kubernetes_manifest" "acs-operator-group" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1"
    "kind"       = "OperatorGroup"
    "metadata"   = {
      "name"      = "rhacs-operator"
      "namespace" = "rhacs-operator"
    }
    "spec" = {
      "upgradeStrategy" = "Default"
    }
  }
}

resource "kubernetes_manifest" "acs-subscription" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata" = {
      "name"      = "rhacs-operator"
      "namespace" = "rhacs-operator"
    }
    "spec" = {
      "channel"             = "stable"
      "installPlanApproval" = "Automatic"
      "name"                = "rhacs-operator"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}

#resource "kubernetes_namespace" "openshift-cluster-csi-drivers" {
#  metadata {
#    name = "openshift-cluster-csi-drivers"
#  }
#}
#
#resource "kubernetes_manifest" "secrets-store-csi-driver-group" {
#  manifest = {
#    "apiVersion" = "operators.coreos.com/v1"
#    "kind"       = "OperatorGroup"
#    "metadata"   = {
#      "name"      = "openshift-cluster-csi-drivers"
#      "namespace" = "openshift-cluster-csi-drivers"
#    }
#    "spec" = {
#      "upgradeStrategy" = "Default"
#    }
#  }
#}