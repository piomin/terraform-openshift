terraform {
  required_version = ">= 0.13"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig
  config_context = var.cluster-context
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig
    config_context = var.cluster-context
  }
}

resource "kubernetes_manifest" "gitops-subscription" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata" = {
      "name"      = "openshift-gitops-operator"
      "namespace" = "openshift-operators"
    }
    "spec" = {
      "channel"             = "latest"
      "installPlanApproval" = "Automatic"
      "name"                = "openshift-gitops-operator"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}

resource "time_sleep" "wait_120_seconds_after_gitops" {
  depends_on = [kubernetes_manifest.gitops-subscription]

  create_duration = "120s"
}

resource "kubernetes_cluster_role_binding_v1" "argocd-application-controller-crb" {
  depends_on = [kubernetes_manifest.gitops-subscription]
  metadata {
    name = "argocd-application-controller-cluster-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    name = "openshift-gitops-argocd-application-controller"
    namespace = "openshift-gitops"
  }
}

resource "helm_release" "argocd-apps" {
  name = "argocd-apps"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = "openshift-gitops"
  version    = "2.0.4"

  values = [
    file("apps.yaml")
  ]

  depends_on       = [time_sleep.wait_120_seconds_after_gitops]

}

resource "kubernetes_namespace" "patch" {
  metadata {
    name = "patch-operator"
  }
}

resource "kubernetes_manifest" "patch-operator-group" {
  depends_on = [kubernetes_namespace.patch]
  manifest = {
    "apiVersion" = "operators.coreos.com/v1"
    "kind"       = "OperatorGroup"
    "metadata" = {
      "name"      = "patch-operator"
      "namespace" = "patch-operator"
    }
    "spec" = {

    }
  }
}

resource "kubernetes_manifest" "path-subscription" {
  depends_on = [kubernetes_namespace.patch, kubernetes_manifest.patch-operator-group]
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata" = {
      "name"      = "patch-operator"
      "namespace" = "patch-operator"
    }
    "spec" = {
      "channel"             = "alpha"
      "installPlanApproval" = "Automatic"
      "name"                = "patch-operator"
      "source"              = "community-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}