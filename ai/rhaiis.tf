resource "time_sleep" "wait_150_seconds-nvidia" {
  depends_on = [kubernetes_manifest.rhai]

  create_duration = "150s"
}

resource "kubernetes_namespace_v1" "namespace-ai" {
  metadata {
    name = "ai"
  }
}

resource "kubectl_manifest" "rhaiis-granite" {
  depends_on = [time_sleep.wait_150_seconds, kubectl_manifest.nvidia-gpu-cluster-policy, kubernetes_namespace_v1.namespace-ai]
  yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: ai
  name: granite-rhaiis
  annotations: {}
spec:
  selector:
    matchLabels:
      app: granite-rhaiis
  replicas: 1
  template:
    metadata:
      labels:
        app: granite-rhaiis
    spec:
      containers:
        - resources:
            limits:
              cpu: '16'
              memory: 30Gi
              nvidia.com/gpu: '1'
            requests:
              cpu: 100m
              memory: 20Gi
              nvidia.com/gpu: '1'
          name: vllm
          image: registry.redhat.io/rhaiis/vllm-cuda-rhel9:latest
          args:
            - vllm serve ibm-granite/granite-3.3-2b-instruct --tensor-parallel-size 1 --max-model-len 131072
          command:
            - /bin/bash
            - -c
          ports:
            - containerPort: 8000
              protocol: TCP
          env:
            - name: HF_HUB_OFFLINE
              value: '0'
YAML
}