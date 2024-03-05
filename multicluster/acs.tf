resource "time_sleep" "wait_60_seconds_after_acs" {
  depends_on = [kubernetes_manifest.acs-subscription]

  create_duration = "60s"
}

resource "kubernetes_namespace" "stackrox" {
  metadata {
    name = "stackrox"
  }
  depends_on = [kubernetes_manifest.acs-subscription]
}

resource "kubernetes_secret" "rhacs-declarative" {
  metadata {
    name = "rhacs-declarative-sec"
    namespace = "stackrox"
  }
  data = {}
  depends_on = [kubernetes_namespace.stackrox]
}

resource "kubernetes_config_map" "rhacs-declarative" {
  metadata {
    name = "rhacs-declarative-cm"
    namespace = "stackrox"
  }
  data = {}
  depends_on = [kubernetes_namespace.stackrox]
}

resource "kubectl_manifest" "acs-central" {
  depends_on = [time_sleep.wait_60_seconds_after_acs, kubernetes_namespace.stackrox]
  yaml_body = <<YAML
kind: Central
apiVersion: platform.stackrox.io/v1alpha1
metadata:
  name: stackrox-central-services
  namespace: stackrox
spec:
  central:
    exposure:
      route:
        enabled: true
    declarativeConfiguration:
      configMaps:
      - name: rhacs-declarative-cm
      secrets:
      - name: rhacs-declarative-sec
    db:
      resources:
        requests:
          cpu: '1'
          memory: 1Gi
        limits:
          cpu: '2'
          memory: 4Gi
YAML
}