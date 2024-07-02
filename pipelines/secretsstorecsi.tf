#resource "helm_release" "secrets-store-csi-driver" {
#  chart            = "secrets-store-csi-driver"
#  name             = "csi-secrets-store"
#  namespace        = "k8s-secrets-store-csi"
#  create_namespace = true
#  repository       = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
#
#  set {
#    name  = "linux.providersDir"
#    value = "/var/run/secrets-store-csi-providers"
#  }
#
#  set {
#    name  = "syncSecret.enabled"
#    value = "true"
#  }
#
#  set {
#    name  = "enableSecretRotation"
#    value = "true"
#  }
#}

#resource "kubernetes_manifest" "vault-database" {
#  manifest = {
#    "apiVersion" = "secrets-store.csi.x-k8s.io/v1alpha1"
#    "kind"       = "SecretProviderClass"
#    "metadata" = {
#      "name"      = "vault-database"
#      "namespace" = "default"
#    }
#    "spec" = {
#      "provider"   = "vault"
#      "parameters" = {
#        "vaultAddress" = "http://vault.vault.svc:8200"
#        "roleName"     = "webapp"
#        "objects"      = "- objectName: \"db-password\"\n  secretPath: \"secret/data/db-pass\"\n  secretKey: \"password\""
#      }
#    }
#  }
#}