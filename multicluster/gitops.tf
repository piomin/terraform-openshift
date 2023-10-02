resource "time_sleep" "wait_90_seconds_after_gitops" {
  depends_on = [kubernetes_manifest.gitops-subscription]

  create_duration = "90s"
}

resource "kubernetes_manifest" "cluster-admins-group" {
  manifest = {
    "apiVersion" = "user.openshift.io/v1"
    "kind"       = "Group"
    "metadata"   = {
      "name" = "cluster-admins"
    }
    "users" = [
      "opentlc-mgr",
      "admin"
    ]
  }
}

resource "kubernetes_manifest" "app-owners" {
  manifest = {
    "apiVersion" = "user.openshift.io/v1"
    "kind"       = "Group"
    "metadata"   = {
      "name" = "app-owners"
    }
    "users" = [
      "pminkows"
    ]
  }
}

resource "kubernetes_cluster_role_binding" "argocd-application-controller-crb" {
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
  version    = "1.2.0"

  values = [
    file("argocd/apps.yaml")
  ]

  depends_on       = [time_sleep.wait_90_seconds_after_gitops]

}