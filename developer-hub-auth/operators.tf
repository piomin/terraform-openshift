resource "kubernetes_namespace" "acm" {
  metadata {
    name = "rhdh-operator"
  }
}

resource "kubernetes_manifest" "rhdh-operator-group" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1"
    "kind"       = "OperatorGroup"
    "metadata"   = {
      "generatedName"  = "rhdh-operator-"
      "namespace"      = "rhdh-operator"
    }
    "spec" = {
      "upgradeStrategy" = "Default"
    }
  }
}

resource "kubernetes_manifest" "acm-subscription" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata" = {
      "name"      = "rhdh"
      "namespace" = "rhdh-operator"
    }
    "spec" = {
      "channel"             = "fast"
      "installPlanApproval" = "Automatic"
      "name"                = "rhdh"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}

resource "kubernetes_namespace" "rhkb" {
  metadata {
    name = "rhkb"
  }
}

resource "kubernetes_manifest" "rhkb-operator-group" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1"
    "kind"       = "OperatorGroup"
    "metadata"   = {
      "generateName"   = "rhkb-"
      "namespace"      = "rhkb"
    }
    "spec" = {
      "upgradeStrategy"  = "Default"
      "targetNamespaces" = ["rhkb"]
    }
  }
}

resource "kubernetes_manifest" "rhkb-subscription" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata" = {
      "name"      = "rhbk-operator"
      "namespace" = "rhbk"
    }
    "spec" = {
      "channel"             = "stable-v26.6"
      "installPlanApproval" = "Automatic"
      "name"                = "rhbk-operator"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}