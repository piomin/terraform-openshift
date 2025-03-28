resource "kubernetes_manifest" "ossm" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata"   = {
      "name"      = "servicemeshoperator"
      "namespace" = "openshift-operators"
    }
    "spec" = {
      "channel"             = "stable"
      "installPlanApproval" = "Automatic"
      "name"                = "servicemeshoperator"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}

resource "kubernetes_namespace" "serverless-namespace" {
  metadata {
    name = "openshift-serverless"
  }
}

resource "kubernetes_manifest" "serverless-group" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1"
    "kind"       = "OperatorGroup"
    "metadata"   = {
      "name"      = "serverless-operator"
      "namespace" = "openshift-serverless"
    }
    "spec" = {
      "upgradeStrategy" = "Default"
    }
  }
}

resource "kubernetes_manifest" "serverless" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata"   = {
      "name"      = "serverless-operator"
      "namespace" = "openshift-serverless"
    }
    "spec" = {
      "channel"             = "stable"
      "installPlanApproval" = "Automatic"
      "name"                = "serverless-operator"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}

resource "kubernetes_manifest" "pipelines" {
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

resource "kubernetes_namespace" "rhai-namespace" {
  metadata {
    name = "redhat-ods-operator"
  }
}

resource "kubernetes_manifest" "rhai-group" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1"
    "kind"       = "OperatorGroup"
    "metadata"   = {
      "name"      = "rhods-operator"
      "namespace" = "redhat-ods-operator"
    }
    "spec" = {
      "upgradeStrategy" = "Default"
    }
  }
}

resource "kubernetes_manifest" "rhai" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata"   = {
      "name"      = "rhods-operator"
      "namespace" = "redhat-ods-operator"
    }
    "spec" = {
      "channel"             = "stable"
      "installPlanApproval" = "Automatic"
      "name"                = "rhods-operator"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}

resource "kubernetes_manifest" "authorino" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata"   = {
      "name"      = "authorino-operator"
      "namespace" = "openshift-operators"
    }
    "spec" = {
      "channel"             = "stable"
      "installPlanApproval" = "Automatic"
      "name"                = "authorino-operator"
      "source"              = "community-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}