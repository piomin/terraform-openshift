resource "kubernetes_namespace" "sealed-secrets" {
  metadata {
    name = "sealed-secrets"
  }
}

resource "kubernetes_service_account" "sealed-secrets" {
  depends_on = [kubernetes_namespace.sealed-secrets]
  metadata {
    name = "sealed-secrets"
    namespace = "sealed-secrets"
  }
}
resource "kubernetes_cluster_role_binding" "sealed-secrets-sa-privileged" {
  depends_on = [kubernetes_service_account.sealed-secrets]
  metadata {
    name = "system:openshift:scc:privileged"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:openshift:scc:privileged"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "sealed-secrets"
    namespace = "sealed-secrets"
  }
}

resource "helm_release" "sealed-secrets" {
  depends_on = [kubernetes_namespace.sealed-secrets, kubernetes_secret.sealed-secrets-key, kubernetes_service_account.sealed-secrets, kubernetes_cluster_role_binding.sealed-secrets-sa-privileged]
  chart      = "sealed-secrets"
  name       = "sealed-secrets"
  namespace  = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets"

  set = [
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = "sealed-secrets"
    }
  ]
}

resource "kubernetes_secret" "sealed-secrets-key" {
  depends_on = [kubernetes_namespace.sealed-secrets]
  metadata {
    name = "sealed-secrets-key"
    namespace = "sealed-secrets"
  }
  data = {
    "tls.crt" = file("keys/tls.crt")
    "tls.key" = file("keys/tls.key")
  }
  type = "kubernetes.io/tls"
}