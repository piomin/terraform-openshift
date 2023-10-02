resource "time_sleep" "wait_60_seconds_after_acs" {
  depends_on = [kubernetes_manifest.acs-subscription]

  create_duration = "60s"
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
YAML
}