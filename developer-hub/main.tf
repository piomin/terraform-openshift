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

resource "kubernetes_namespace" "backstage" {
  metadata {
    name = "backstage"
  }
}

resource "kubernetes_config_map" "dynamic-plugins-rhdh" {
  metadata {
    name = "dynamic-plugins-rhdh"
    namespace = "backstage"
  }
  data = {
    "dynamic-plugins.yaml" = file("dynamic-plugins.yaml")
  }
  depends_on = [kubernetes_namespace.backstage]
}

resource "kubernetes_config_map" "app-config-rhdh" {
  metadata {
    name = "app-config-rhdh"
    namespace = "backstage"
  }
  data = {
    "app-config-rhdh.yaml" = file("app-config.yaml")
  }
  depends_on = [kubernetes_namespace.backstage]
}

resource "kubernetes_secret" "default-token" {
  metadata {
    name = "default-token"
    namespace = "backstage"
    annotations = {
      kubernetes.io/service-account.name = "default"
    }
  }
  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_secret" "app-secrets-rhdh" {
  metadata {
    name = "app-secrets-rhdh"
    namespace = "backstage"
  }
  data = {
    GITHUB_ORG = var.github-org
    SONARQUBE_URL = "https://sonarcloud.io"
    SONARQUBE_TOKEN = var.sonar-token
    GITHUB_TOKEN = var.github-token
    GITHUB_CLIENT_ID = var.github-client-id
    GITHUB_CLIENT_SECRET = var.github-client-secret
    ARGOCD_TOKEN = var.argocd-token
    OPENSHIFT_TOKEN = var.openshift-token
    AZURE_TOKEN = var.azure-token
    AZURE_ORG = var.azure-org
  }
}

resource "kubectl_manifest" "basic" {
  depends_on = [kubernetes_namespace.backstage, kubernetes_config_map.dynamic-plugins-rhdh]
  yaml_body = <<YAML
apiVersion: rhdh.redhat.com/v1alpha1
kind: Backstage
metadata:
  name: developer-hub
  namespace: backstage
spec:
  application:
    appConfig:
      configMaps:
        - name: app-config-rhdh
      mountPath: /opt/app-root/src
    dynamicPluginsConfigMapName: dynamic-plugins-rhdh
    extraEnvs:
      secrets:
        - name: app-secrets-rhdh
    extraFiles:
      mountPath: /opt/app-root/src
    replicas: 1
    route:
      enabled: true
  database:
    enableLocalDb: true
YAML
}