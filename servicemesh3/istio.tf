resource "kubectl_manifest" "gateway" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: microservices-gateway
  namespace: mesh
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
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: quarkus-insurance-app-vs
  namespace: mesh
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
  yaml_body  = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: quarkus-person-app-dr
  namespace: mesh
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
  yaml_body  = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: quarkus-person-app-vs-via-gw
  namespace: mesh
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
  yaml_body  = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: quarkus-person-app-vs
  namespace: mesh
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

