resource "time_sleep" "wait_60_seconds_after_acs" {
  depends_on = [kubernetes_manifest.acs-subscription]

  create_duration = "60s"
}

resource "kubernetes_secret" "rhacs-declarative" {
  metadata {
    name = "rhacs-declarative"
    namespace = "rhacs-operator"
  }
  data = {}
  depends_on = [kubernetes_manifest.acs-subscription]
}

resource "kubernetes_config_map" "rhacs-declarative" {
  metadata {
    name = "rhacs-declarative"
    namespace = "rhacs-operator"
  }
  data = {}
  depends_on = [kubernetes_manifest.acs-subscription]
}

resource "kubectl_manifest" "acs-central" {
  depends_on = [time_sleep.wait_60_seconds_after_acs, kubernetes_manifest.acs-subscription]
  yaml_body = <<YAML
kind: Central
apiVersion: platform.stackrox.io/v1alpha1
metadata:
  name: stackrox-central-services
  namespace: rhacs-operator
spec:
  central:
    exposure:
      route:
        enabled: true
    declarativeConfiguration:
      configMaps:
      - name: rhacs-declarative
      secrets:
      - name: rhacs-declarative
YAML
}