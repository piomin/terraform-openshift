resource "kubernetes_manifest" "tracing-group" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1"
    "kind"       = "OperatorGroup"
    "metadata"   = {
      "name"      = "openshift-distributed-tracing"
      "namespace" = "openshift-distributed-tracing"
    }
    "spec" = {
      "upgradeStrategy" = "Default"
    }
  }
}

resource "kubernetes_manifest" "tracing" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata" = {
      "name"      = "jaeger-product"
      "namespace" = "openshift-distributed-tracing"
    }
    "spec" = {
      "channel"             = "stable"
      "installPlanApproval" = "Automatic"
      "name"                = "jaeger-product"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}

resource "kubernetes_manifest" "kiali" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata" = {
      "name"      = "kiali-ossm"
      "namespace" = "openshift-operators"
    }
    "spec" = {
      "channel"             = "stable"
      "installPlanApproval" = "Automatic"
      "name"                = "kiali-ossm"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}

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

resource "kubernetes_manifest" "ossmconsole" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata"   = {
      "name"      = "ossmconsole"
      "namespace" = "openshift-operators"
    }
    "spec" = {
      "channel"             = "candidate"
      "installPlanApproval" = "Automatic"
      "name"                = "ossmconsole"
      "source"              = "community-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}