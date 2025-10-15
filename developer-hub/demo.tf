resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo"
  }
}

resource "kubectl_manifest" "task-maven-get-project-version" {
  depends_on = [kubernetes_namespace.demo]
  yaml_body = <<YAML
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: maven-get-project-version
  namespace: demo
spec:
  params:
    - default: >-
        image-registry.openshift-image-registry.svc:5000/openshift/java:latest
      description: Maven base image
      name: MAVEN_IMAGE
      type: string
    - default: .
      description: >-
        The context directory within the repository for sources on which we want
        to execute maven goals.
      name: CONTEXT_DIR
      type: string
  results:
    - description: Project version read from pom.xml
      name: version
  steps:
    - image: $(params.MAVEN_IMAGE)
      name: mvn-command
      resources: {}
      script: >
        #!/usr/bin/env bash

        VERSION=$(/usr/bin/mvn help:evaluate -Dexpression=project.version -q
        -DforceStdout)

        echo -n $VERSION | tee $(results.version.path)
      workingDir: $(workspaces.source.path)/$(params.CONTEXT_DIR)
  workspaces:
    - name: source
YAML
}

locals {
  my_manifest = yamldecode(file("manifests/task.yaml"))
}

resource "kubernetes_manifest" "task-sonarqube-scanner" {
  manifest = local.my_manifest
}

resource "kubernetes_config_map" "maven-settings" {
  depends_on = [kubernetes_namespace.demo]
  metadata {
    name = "maven-settings"
    namespace = "demo"
  }
  data = {
    "settings.xml" = file("manifests/settings.xml")
  }
}

resource "kubectl_manifest" "sonarqube-secret-token" {
  depends_on = [kubernetes_namespace.demo]
  yaml_body = <<YAML
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  annotations:
    sealedsecrets.bitnami.com/cluster-wide: "true"
  creationTimestamp: null
  name: sonarqube-secret-token
  namespace: demo
spec:
  encryptedData:
    sonar-project.properties: AgB8yEvAr2hTep74ajYTI0QGASFLxFbrHIjKNpj4J8IQbCYssTkM4v61k6kvAQ7JxcjDd7oj8LpjNh0Y7IKdlQ08Uc8ji+gH1wf3WjL1M95lvkjQ75ol2WYXEb5v6qpze/rS5BFD5USn215DPlFHYn3N7N8VE30SH1Ny8PlYV23adswF73Huqxy8vZJkDIHLe3w6r9s6F+qu/0LGt2psWSGDyXL+EKM8xdf2WzBKd869+EZCHB7sJGHNsGBuBvOPH12Tehgr3jExBjTJ+Sm096pUZfiB77ULFu3IQYBZCBVLXfqDiflALyY5YOJa6ae+npP2tUirZbA/BdbBbeXZl+d6J9SCw+JnW145a322FF8/tbbDiWuzkIQ2LBJa7veHdPormTcAuUiVl7zFpCIlVibherGop346vl8V2rWsSZTl8e+TAcUyG1FpL36cM7QnrR1B3NDG6Rl9tAFZH6KE5huQzB+U55ny8O3aAE4uK7SjZ/iS1VlQuLoWYgn2tcMdVE7uH5dcN3pWhkGx4THUK3i2WfTPGPkgbHOKlnOzLuO7h2MtKllEGvmgirbmuqO9YOcRmsBP0HxVX7JKDB2DSTyfOdegfWE5HJmQGAhexImeGxUlK6trEFZVhVOWaJU+E9QKHAcKHTgt1gAFho39ssJnCn0hkh7pv6873audrim/KYaMexg4w43niyfMHzBUPaDLi9Vp5MS2AJFKAZ81XTqeL4BUmwT6AeudZ4JVmmx34x+Vpvgz5MfN6hePtQur2DDvZB5Ykmsyy+skSm/g8pJNsJWBuoWbKmBdIu7KNhze+wnMM3eZ4GCwoZlxRRbALy/g6AcEXNTXP11ql6qu5wmBn2k0ObAYXqFFkDfGkERXcRf//Ggz2dmQpRap0e/1uQ==
  template:
    metadata:
      annotations:
        sealedsecrets.bitnami.com/cluster-wide: "true"
      creationTimestamp: null
      name: sonarqube-secret-token
    type: Opaque
YAML
}

resource "kubectl_manifest" "pminkows-piomin-pull-secret" {
  depends_on = [kubernetes_namespace.demo]
  yaml_body = <<YAML
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  annotations:
    sealedsecrets.bitnami.com/cluster-wide: "true"
  creationTimestamp: null
  name: pminkows-piomin-pull-secret
  namespace: demo
spec:
  encryptedData:
    .dockerconfigjson: AgAo4dFq2hYiQVqz7dygl/+tKUpd0qCFLxpa+jZZH22Qr+mCGYqaggb0WuXEMUT+nhu6Gkh2RjNqN136Xedlc9pVn+EsUF2UjfWfD0iNcbQG14VAYmgP8fe2tOzsxX9v8CmKBmCOBg0Q2hrLPVHGzGdiFVNQtP6eXfeCTlfF9nygZmOpR/9V93H+Z+7KC8FXj15KCxaeWa2GJrw+SGva73r5zTKVIiZ6umyQJargbCPc7qqEAkxnwyLG/+ap3vvOxUVPgDs6GR5IILlPEWZa0vhFJVNSKZ2YSWuxeyfU2t9IC2HpivRinidfbXfQiwn9RvxQ3nkErq5QFYNIgIRam046SmDaBvhVpCmtbwgBo1QKvR6rCQ0pzKQzcAsNPsh+10rctIx6EylpDoTY+FKyiey1g6vzN3wQoPjaK3CpWZr9XG1uOaYAN46S44nR3Vk0YcwplQjqlNrWSZvoKjYw6S/ryvJyrnLMxV0kOiFzHVdgLr1z+jpki3bPw6+IoU6ouMnIS31NvEBW3kGT5yNpnDnXAgLXoUvk8uR9uWIStBXaQIt8DnppnXewohwRe2XmWQsI1HKbVwHNsymVNf8OOOu0j53ksbPHhRgoN69M0Sg+SdYpEWVtWy/LbzTuXQQEpLgAJAr5YtoctQWG6LEmxUCpeT4yMGFVw4zMU8+PdECGoOvdP6RYoFq/xmuQ2TT19HutKPzyNt6QF2VndK+VbiG/qbbcbg3c1yN9UHygP4UhrGIikf0MeeNworZxsO6CnBP0xFX84gCyrk4I+lfBChw626B4VaBiL58klyL1PFnIbBUAsRrV+YUoJBZRuRlBl4b8H1HG4vMwEE8NQX0f/DhlqcJrV5YLbW/wUWr+w51bD2HbEnXZoi75F8O5UpvCe+5twRN+Lt7zmO0ja8+cuCl0grJeiuwTNFykOG/CM0ASGi8Mg616eRWRkgZc
  template:
    metadata:
      annotations:
        sealedsecrets.bitnami.com/cluster-wide: "true"
      creationTimestamp: null
      name: pminkows-piomin-pull-secret
    type: kubernetes.io/dockerconfigjson
YAML
}