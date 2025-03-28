resource "kubernetes_namespace" "rhai-apps-namespace" {
  metadata {
    name = "rhai"
  }
}

resource "time_sleep" "wait_150_seconds" {
  depends_on = [kubernetes_manifest.rhai]

  create_duration = "150s"
}

resource "kubectl_manifest" "data-science-cluster" {
  depends_on = [time_sleep.wait_150_seconds, kubernetes_namespace.rhai-apps-namespace]
  yaml_body = <<YAML
apiVersion: datasciencecluster.opendatahub.io/v1
kind: DataScienceCluster
metadata:
  labels:
    app.kubernetes.io/created-by: rhods-operator
    app.kubernetes.io/instance: default-dsc
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/name: datasciencecluster
    app.kubernetes.io/part-of: rhods-operator
  name: default-dsc
  namespace: rhai
spec:
  components:
    codeflare:
      managementState: Managed
    dashboard:
      managementState: Managed
    datasciencepipelines:
      managementState: Managed
    kserve:
      serving:
        ingressGateway:
          certificate:
            type: OpenshiftDefaultIngress
        managementState: Managed
        name: knative-serving
      managementState: Managed
    kueue:
      managementState: Managed
    modelmeshserving:
      managementState: Managed
    modelregistry:
      managementState: Removed
      registriesNamespace: rhoai-model-registries
    ray:
      managementState: Managed
    trainingoperator:
      managementState: Removed
    trustyai:
      managementState: Managed
    workbenches:
      managementState: Managed
YAML
}