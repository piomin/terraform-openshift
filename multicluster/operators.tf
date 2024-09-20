# resource "kubernetes_namespace" "acm" {
#   metadata {
#     name = "open-cluster-management"
#   }
# }
#
# resource "kubernetes_manifest" "acm-operator-group" {
#   manifest = {
#     "apiVersion" = "operators.coreos.com/v1"
#     "kind"       = "OperatorGroup"
#     "metadata"   = {
#       "name"      = "open-cluster-management"
#       "namespace" = "open-cluster-management"
#     }
#     "spec" = {
#       "upgradeStrategy" = "Default"
#       "targetNamespaces" = ["open-cluster-management"]
#     }
#   }
# }
#
# resource "kubernetes_manifest" "acm-subscription" {
#   manifest = {
#     "apiVersion" = "operators.coreos.com/v1alpha1"
#     "kind"       = "Subscription"
#     "metadata" = {
#       "name"      = "acm-operator-subscription"
#       "namespace" = "open-cluster-management"
#     }
#     "spec" = {
#       "channel"             = "release-2.9"
#       "installPlanApproval" = "Automatic"
#       "name"                = "advanced-cluster-management"
#       "source"              = "redhat-operators"
#       "sourceNamespace"     = "openshift-marketplace"
#     }
#   }
# }

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

# resource "kubernetes_manifest" "gitops-subscription" {
#   manifest = {
#     "apiVersion" = "operators.coreos.com/v1alpha1"
#     "kind"       = "Subscription"
#     "metadata" = {
#       "name"      = "openshift-gitops-operator"
#       "namespace" = "openshift-operators"
#     }
#     "spec" = {
#       "channel"             = "latest"
#       "installPlanApproval" = "Automatic"
#       "name"                = "openshift-gitops-operator"
#       "source"              = "redhat-operators"
#       "sourceNamespace"     = "openshift-marketplace"
#     }
#   }
# }

# resource "kubernetes_manifest" "pipelines-subscription" {
#   manifest = {
#     "apiVersion" = "operators.coreos.com/v1alpha1"
#     "kind"       = "Subscription"
#     "metadata" = {
#       "name"      = "openshift-pipelines-operator-rh"
#       "namespace" = "openshift-operators"
#     }
#     "spec" = {
#       "channel"             = "latest"
#       "installPlanApproval" = "Automatic"
#       "name"                = "openshift-pipelines-operator-rh"
#       "source"              = "redhat-operators"
#       "sourceNamespace"     = "openshift-marketplace"
#     }
#   }
# }

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