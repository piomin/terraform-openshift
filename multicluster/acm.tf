# resource "time_sleep" "wait_60_seconds" {
#   depends_on = [kubernetes_manifest.acm-subscription]
#
#   create_duration = "60s"
# }
#
# resource "kubectl_manifest" "acm-hub" {
#   depends_on = [time_sleep.wait_60_seconds, kubernetes_manifest.acm-subscription]
#   yaml_body = <<YAML
# apiVersion: operator.open-cluster-management.io/v1
# kind: MultiClusterHub
# metadata:
#   name: multiclusterhub
#   namespace: open-cluster-management
# spec: {}
# YAML
# }