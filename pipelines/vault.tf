resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "kubernetes_service_account" "vault-sa" {
  depends_on = [kubernetes_namespace.vault]
  metadata {
    name      = "vault"
    namespace = "vault"
  }
}

resource "kubernetes_secret_v1" "vault-secret" {
  depends_on = [kubernetes_namespace.vault]
  metadata {
    name = "vault-token"
    namespace = "vault"
    annotations = {
      "kubernetes.io/service-account.name" = "vault"
    }
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role_binding" "privileged" {
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
    name      = "secrets-store-csi-driver"
    namespace = "k8s-secrets-store-csi"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "vault-csi-provider"
    namespace = "vault"
  }
}

resource "helm_release" "vault" {
  chart            = "hashicorp/vault"
  name             = "vault"
  namespace        = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  version = "0.27.0"

  values = [
    file("vault/values.yaml")
  ]
}

#resource "time_sleep" "wait_120_seconds" {
#  depends_on = [helm_release.vault]
#
#  create_duration = "120s"
#}
#
#resource "vault_auth_backend" "kubernetes" {
#  depends_on = [time_sleep.wait_120_seconds]
#  type = "kubernetes"
#}
#
#resource "vault_kv_secret_v2" "secret-1" {
#  mount = "secret"
#  name = "sonarqube-token"
#  data_json = jsonencode(
#    {
#      api_token = "f6b415dd54f74a7e3361976820544c2b138791d4"
#    }
#  )
#}
#
#resource "vault_kv_secret_v2" "secret-2" {
#  mount = "secret"
#  name = "jira-token"
#  data_json = jsonencode(
#    {
#      api_token = "K22TUmUBe4ZYnxW3ANur7BB7"
#    }
#  )
#}
#
#data "kubernetes_secret" "vault-token" {
#  metadata {
#    name      = "vault-token"
#    namespace = "vault"
#  }
#}
#
#resource "vault_kubernetes_auth_backend_config" "example" {
#  backend                = vault_auth_backend.kubernetes.path
#  kubernetes_host        = "https://172.30.0.1:443"
#  kubernetes_ca_cert     = data.kubernetes_secret.vault-token.data["ca.crt"]
#  token_reviewer_jwt     = data.kubernetes_secret.vault-token.data.token
#}
#
#resource "vault_policy" "internal-app" {
#  name = "internal-app"
#
#  policy = <<EOT
#path "secret/data/sonarqube-token" {
#  capabilities = ["read"]
#}
#path "secret/data/jira-token" {
#  capabilities = ["read"]
#}
#EOT
#}
#
#resource "kubernetes_service_account" "webapp-sa" {
#  metadata {
#    name      = "webapp-sa"
#    namespace = "demo-ci"
#  }
#}
#
#resource "vault_kubernetes_auth_backend_role" "internal-role" {
#  backend                          = vault_auth_backend.kubernetes.path
#  role_name                        = "webapp"
#  bound_service_account_names      = ["webapp-sa"]
#  bound_service_account_namespaces = ["demo-ci"]
#  token_ttl                        = 3600
#  token_policies                   = ["internal-app"]
#}