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
  config_path = var.kubeconfig
  config_context = var.cluster-context
}

provider "kubectl" {
  config_path = var.kubeconfig
  config_context = var.cluster-context
}

resource "kubernetes_namespace" "rhdh" {
  metadata {
    name = "rhdh"
  }
}

resource "kubernetes_config_map" "dynamic-plugins-rhdh" {
  metadata {
    name = "rhdh-dynamic-plugins"
    namespace = "backstage"
  }
  data = {
    "dynamic-plugins.yaml" = file("files/dynamic-plugins.yaml")
  }
  depends_on = [kubernetes_namespace.rhdh]
}

resource "kubernetes_config_map" "app-config-rhdh" {
  metadata {
    name = "rhdh-app-config"
    namespace = "rhdh"
  }
  data = {
    "app-config.yaml" = file("files/app-config.yaml")
  }
  depends_on = [kubernetes_namespace.rhdh]
}

resource "kubernetes_config_map" "rbac-policies" {
  metadata {
    name = "rbac-policies"
    namespace = "rhdh"
  }
  data = {
    "rbac-conditional-policies.yaml" = file("files/rbac-conditional-policies.yaml")
    "rbac-policies.csv" = file("files/rbac-policies.csv")
  }
  depends_on = [kubernetes_namespace.rhdh]
}

resource "kubernetes_secret" "app-secrets-rhdh" {
  metadata {
    name = "app-secrets-rhdh"
    namespace = "rhdh"
  }
  data = {
    KEYCLOAK_BASE_URL = "https://keycloak.apps.${var.domain}"
    KEYCLOAK_CLIENT_ID = "rhdh"
    KEYCLOAK_CLIENT_SECRET = var.keycloak-client-secret
    KEYCLOAK_REALM = "rhdh"
    SESSION_SECRET = "MFfvGJrViqtlCgCDYhvOIUm3UaMHYqAVnZoN06d2ydP3pizFGe8qjh0sa9PfiBs/"
  }
}

resource "kubectl_manifest" "basic" {
  depends_on = [kubernetes_config_map.dynamic-plugins-rhdh]
  yaml_body = <<YAML
apiVersion: rhdh.redhat.com/v1alpha3
kind: Backstage
metadata:
  name: developer-hub
  namespace: rhdh
spec:
  application:
    appConfig:
      configMaps:
        - name: rhdh-app-config
      mountPath: /opt/app-root/src
    dynamicPluginsConfigMapName: rhdh-dynamic-plugins
    extraEnvs:
      secrets:
        - name: rhdh-keycloak
    extraFiles:
      configMaps:
        - name: rbac-policies
      mountPath: /opt/app-root/src
    route:
      enabled: true
  database:
    enableLocalDb: true
  monitoring:
    enabled: false
YAML
}