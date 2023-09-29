resource "kubernetes_namespace" "istio" {
  metadata {
    name = "istio"
  }
}

resource "time_sleep" "wait_120_seconds" {
  depends_on = [kubernetes_manifest.ossm]

  create_duration = "120s"
}

resource "kubectl_manifest" "basic" {
  depends_on = [time_sleep.wait_120_seconds, kubernetes_namespace.istio]
  yaml_body = <<YAML
kind: ServiceMeshControlPlane
apiVersion: maistra.io/v2
metadata:
  name: basic
  namespace: istio
spec:
  version: v2.4
  tracing:
    type: Jaeger
    sampling: 10000
  policy:
    type: Istiod
  telemetry:
    type: Istiod
  addons:
    jaeger:
      install:
        storage:
          type: Memory
    prometheus:
      enabled: true
    kiali:
      enabled: true
    grafana:
      enabled: true
YAML
}

resource "kubectl_manifest" "console" {
  depends_on = [time_sleep.wait_120_seconds, kubernetes_namespace.istio]
  yaml_body = <<YAML
kind: OSSMConsole
apiVersion: kiali.io/v1alpha1
metadata:
  name: ossmconsole
  namespace: istio
spec:
  kiali:
    serviceName: ''
    serviceNamespace: ''
    servicePort: 0
    url: ''
YAML
}

resource "time_sleep" "wait_60_seconds_2" {
  depends_on = [kubectl_manifest.basic]

  create_duration = "60s"
}

resource "kubectl_manifest" "access" {
  depends_on = [time_sleep.wait_120_seconds, kubernetes_namespace.istio, kubernetes_namespace.demo-apps]
  yaml_body = <<YAML
apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
  namespace: istio
spec:
  members:
    - demo-apps
YAML
}

resource "kubectl_manifest" "gateway" {
  depends_on = [time_sleep.wait_60_seconds_2, kubernetes_namespace.demo-apps]
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: microservices-gateway
  namespace: demo-apps
spec:
  selector:
    istio: ingressgateway
  servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
        - quarkus-insurance-app.apps.${var.domain}
        - quarkus-person-app.apps.${var.domain}
YAML
}

resource "kubectl_manifest" "quarkus-insurance-app-vs" {
  depends_on = [time_sleep.wait_60_seconds_2, kubernetes_namespace.demo-apps]
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: quarkus-insurance-app-vs
  namespace: demo-apps
spec:
  hosts:
    - quarkus-insurance-app.apps.${var.domain}
  gateways:
    - microservices-gateway
  http:
    - match:
        - uri:
            prefix: "/insurance"
      rewrite:
        uri: " "
      route:
        - destination:
            host: quarkus-insurance-app
          weight: 100
YAML
}

resource "kubectl_manifest" "quarkus-person-app-dr" {
  depends_on = [time_sleep.wait_60_seconds_2, kubernetes_namespace.demo-apps]
  yaml_body  = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: quarkus-person-app-dr
  namespace: demo-apps
spec:
  host: quarkus-person-app
  subsets:
    - name: v1
      labels:
        version: v1
    - name: v2
      labels:
        version: v2
YAML
}

resource "kubectl_manifest" "quarkus-person-app-vs-via-gw" {
  depends_on = [time_sleep.wait_60_seconds_2, kubernetes_namespace.demo-apps]
  yaml_body  = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: quarkus-person-app-vs-via-gw
  namespace: demo-apps
spec:
  hosts:
    - quarkus-person-app.apps.${var.domain}
  gateways:
    - microservices-gateway
  http:
    - match:
      - uri:
          prefix: "/person"
      rewrite:
        uri: " "
      route:
        - destination:
            host: quarkus-person-app
            subset: v1
          weight: 100
        - destination:
            host: quarkus-person-app
            subset: v2
          weight: 0
YAML
}

resource "kubectl_manifest" "quarkus-person-app-vs" {
  depends_on = [time_sleep.wait_60_seconds_2, kubernetes_namespace.demo-apps]
  yaml_body  = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: quarkus-person-app-vs
  namespace: demo-apps
spec:
  hosts:
    - quarkus-person-app
  http:
    - route:
        - destination:
            host: quarkus-person-app
            subset: v1
          weight: 100
        - destination:
            host: quarkus-person-app
            subset: v2
          weight: 0
YAML
}

