resource "kubernetes_manifest" "ossm" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata"   = {
      "name"      = "servicemeshoperator3"
      "namespace" = "openshift-operators"
    }
    "spec" = {
      "channel"             = "stable"
      "installPlanApproval" = "Automatic"
      "name"                = "servicemeshoperator3"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}

resource "kubernetes_manifest" "kiali" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata" = {
      "name"      = "kiali-ossm"
      "namespace" = "openshift-operators"
    }
    "spec" = {
      "channel"             = "stable"
      "installPlanApproval" = "Automatic"
      "name"                = "kiali-ossm"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}

resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
  }
}

resource "kubernetes_namespace" "istio-cni" {
  metadata {
    name = "istio-cni"
  }
}

resource "kubernetes_namespace" "istio-gateway" {
  metadata {
    name = "istio-gateway"
  }
}

resource "kubernetes_namespace" "kiali" {
  metadata {
    name = "kiali"
  }
}

resource "kubernetes_cluster_role_binding" "kiali-monitoring-rbac" {
  metadata {
    name = "kiali-monitoring-rbac"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-monitoring-view"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "kiali-service-account"
    namespace = "kiali"
  }
}

resource "kubectl_manifest" "istio-cni" {
  yaml_body = <<YAML
apiVersion: sailoperator.io/v1
kind: IstioCNI
metadata:
  name: default
spec:
  namespace: istio-cni
  version: v1.28.6
YAML
}

resource "kubectl_manifest" "istio" {
yaml_body = <<YAML
apiVersion: sailoperator.io/v1
kind: Istio
metadata:
  name: default
spec:
  namespace: istio-system
  updateStrategy:
    inactiveRevisionDeletionGracePeriodSeconds: 30
    type: InPlace
  values:
    meshConfig:
      enableTracing: true
      extensionProviders:
        - name: otel
          opentelemetry:
            port: 4317
            service: platform-otel-collector.tracing.svc.cluster.local
  version: v1.28.6
YAML
}

resource "kubectl_manifest" "telemetry" {
  yaml_body = <<YAML
apiVersion: telemetry.istio.io/v1
kind: Telemetry
metadata:
  name: otel-demo
  namespace: istio-system
spec:
  metrics:
    - providers:
        - name: prometheus
  tracing:
    - providers:
        - name: otel
      randomSamplingPercentage: 100
YAML
}

resource "kubectl_manifest" "kiali" {
  yaml_body = <<YAML
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
  namespace: kiali
spec:
  login_token:
    expiration_seconds: 86400
  server:
    audit_log: true
    port: 20001
    observability:
      metrics:
        enabled: true
        health_status:
          enabled: false
          max_consecutive_na: 3
        port: 9090
      tracing:
        collector_type: otel
        collector_url: 'jaeger-collector.istio-system:4318'
        enabled: false
        otel:
          protocol: http
          skip_verify: false
          tls_enabled: false
        sampling_rate: 0.5
    write_timeout: 60s
    require_auth: true
    profiler:
      enabled: false
    web_history_mode: browser
    cors_allow_all: false
    gzip_enabled: true
  health_config:
    compute:
      duration: 5m
      refresh_interval: 3m
      timeout: 10m
  deployment:
    network_policy:
      enabled: true
    probes:
      liveness:
        initial_delay_seconds: 5
        period_seconds: 30
      readiness:
        initial_delay_seconds: 5
        period_seconds: 30
      startup:
        failure_threshold: 6
        initial_delay_seconds: 30
        period_seconds: 10
    remote_cluster_resources_only: false
    image_digest: ''
    image_pull_policy: IfNotPresent
    cluster_wide_access: true
    logger:
      log_format: text
      log_level: info
      sampler_rate: '1'
      time_field_format: '2006-01-02T15:04:05Z07:00'
    ingress:
      class_name: nginx
    instance_name: kiali
    secret_name: kiali
    replicas: 1
    view_only_mode: false
  auth:
    openid:
      api_token: id_token
      authentication_timeout: 300
      disable_rbac: false
      insecure_skip_verify_tls: false
      username_claim: sub
    openshift:
      insecure_skip_verify_tls: false
  clustering:
    autodetect_secrets:
      enabled: true
      label: kiali.io/multiCluster=true
    enable_exec_provider: false
    ignore_home_cluster: false
  istio_labels:
    egress_gateway_label: istio=egressgateway
    ingress_gateway_label: istio=ingressgateway
    injection_label_name: istio-injection
    injection_label_rev: istio.io/rev
  chat_ai:
    enabled: false
    store_config:
      enabled: true
      max_cache_memory_mb: 1024
      reduce_threshold: 15
      reduce_with_ai: false
  external_services:
    custom_dashboards:
      discovery_auto_threshold: 10
      discovery_enabled: auto
      enabled: true
      is_core: false
      namespace_label: namespace
      prometheus:
        auth:
          insecure_skip_verify: false
          type: none
          use_kiali_token: false
        cache_duration: 7
        cache_enabled: true
        cache_expiration: 300
        is_core: true
        thanos_proxy:
          enabled: false
          retention_period: 7d
          scrape_interval: 30s
    grafana:
      auth:
        insecure_skip_verify: false
        type: none
        use_kiali_token: false
      enabled: false
      internal_url: 'http://grafana.istio-system:3000'
      is_core: false
    istio:
      istio_sidecar_annotation: sidecar.istio.io/status
      istio_injection_annotation: sidecar.istio.io/inject
      istiod_polling_interval_seconds: 20
      envoy_admin_local_port: 15000
      istio_api_enabled: true
      istiod_pod_monitoring_port: 15014
      component_status:
        enabled: true
      istio_identity_domain: svc.cluster.local
      validation_reconcile_interval: 1m
      validation_change_detection_enabled: true
    perses:
      auth:
        insecure_skip_verify: false
        type: none
        use_kiali_token: false
      enabled: false
      is_core: false
      project: istio
      url_format: ''
    prometheus:
      auth:
        insecure_skip_verify: true
        type: bearer
        use_kiali_token: true
      cache_duration: 7
      cache_enabled: true
      cache_expiration: 300
      is_core: true
      thanos_proxy:
        enabled: true
        retention_period: 7d
        scrape_interval: 30s
      url: 'https://thanos-querier.openshift-monitoring.svc.cluster.local:9091'
    tracing:
      enabled: true
      grpc_port: 9095
      namespace_selector: true
      tempo_config:
        cache_capacity: 200
        cache_enabled: true
        name: platform-tracing-stack
        namespace: tracing
        tenant: platform
        url_format: openshift
      auth:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt
        insecure_skip_verify: true
        type: bearer
        use_kiali_token: true
      query_timeout: 5
      disable_version_check: true
      internal_url: 'https://tempo-platform-tracing-stack-gateway.tracing.svc.cluster.local:8080/api/traces/v1/platform/tempo'
      provider: tempo
      use_waypoint_name: false
      is_core: false
      health_check_url: 'https://tempo-platform-tracing-stack-gateway.tracing.svc.cluster.local:8080/api/traces/v1/platform/tempo/api/echo'
      use_grpc: false
      external_url: 'https://tempo-platform-tracing-stack-gateway-tracing.apps.piomin.australiaeast.aroapp.io/api/traces/v1/platform/search'
  version: default
  kubernetes_config:
    burst: 200
    cache_duration: 300
    cache_token_namespace_duration: 10
    qps: 175
  kiali_feature_flags:
    certificates_information_indicators:
      enabled: false
    clustering:
      enable_exec_provider: false
    istio_annotation_action: true
    istio_injection_action: true
    istio_upgrade_action: false
    ui_defaults:
      graph:
        settings:
          animation: point
        traffic:
          ambient: total
          grpc: requests
          http: requests
          tcp: sent
      i18n:
        show_selector: false
      list:
        include_health: true
        include_istio_resources: true
        include_validations: true
        show_include_toggles: false
      metrics_per_refresh: 1m
      refresh_interval: 1m
      tracing:
        limit: 100
    validations:
      skip_wildcard_gateway_hosts: true
YAML
}