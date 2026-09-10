resource "time_sleep" "wait_150_seconds-nvidia" {
  depends_on = [kubernetes_manifest.rhai]

  create_duration = "150s"
}

resource "kubernetes_namespace_v1" "namespace-ai" {
  metadata {
    name = "ai"
  }
}

resource "kubectl_manifest" "rhaiis-qwen3-coder" {
  depends_on = [time_sleep.wait_150_seconds, kubectl_manifest.nvidia-gpu-cluster-policy, kubernetes_namespace_v1.namespace-ai]
  yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: ai
  name: qwen3-coder
  annotations: {}
spec:
  selector:
    matchLabels:
      app: qwen3-coder
  replicas: 1
  template:
    metadata:
      labels:
        app: qwen3-coder
    spec:
      containers:
        - resources:
            limits:
              cpu: '16'
              memory: 30Gi
              nvidia.com/gpu: '1'
            requests:
              cpu: '1'
              memory: 10Gi
              nvidia.com/gpu: '1'
          name: vllm
          image: registry.redhat.io/rhaiis/vllm-cuda-rhel9:3.4.4
          command:
            - python
            - '-m'
            - vllm.entrypoints.openai.api_server
          args:
            - '--port=8000'
            - '--model=RedHatAI/Qwen3-Coder-Next-NVFP4'
            - '--served-model-name=qwen3_coder'
            - '--tensor-parallel-size=2'
            - '--tool-call-parser=qwen3_coder'
            - '--enforce-eager'
          ports:
            - containerPort: 8000
              protocol: TCP
          env:
            - name: HF_HUB_OFFLINE
              value: '0'
            - name: HUGGING_FACE_HUB_TOKEN
              value: <TOKEN>
YAML
}

resource "kubectl_manifest" "rhaiis-qwen3-coder" {
  depends_on = [time_sleep.wait_150_seconds, kubectl_manifest.nvidia-gpu-cluster-policy, kubernetes_namespace_v1.namespace-ai]
  yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  name: qwen3-coder
  namespace: ai
spec:
  selector:
    app: qwen3-coder
  ports:
    - protocol: TCP
      port: 8000
      targetPort: 8000
YAML
}
