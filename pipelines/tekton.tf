# resource "kubernetes_namespace" "demo-ci" {
#   metadata {
#     name = "demo-ci"
#   }
# }

#resource "time_sleep" "wait_120_seconds" {
#  depends_on = [kubernetes_manifest.pipelines-subscription]
#
#  create_duration = "120s"
#}
#
#resource "kubectl_manifest" "sonarqube_task" {
#  depends_on = [time_sleep.wait_120_seconds, kubernetes_namespace.demo-ci]
#  yaml_body = <<YAML
#apiVersion: tekton.dev/v1beta1
#kind: Task
#metadata:
#  name: sonarqube-scanner
#  labels:
#    app.kubernetes.io/version: '1.0'
#spec:
#  params:
#    - default: ''
#      description: Host URL where the sonarqube server is running
#      name: SONAR_HOST_URL
#      type: string
#    - default: ''
#      description: Project's unique key
#      name: SONAR_PROJECT_KEY
#      type: string
#  steps:
#    - image: 'registry.access.redhat.com/ubi8/ubi-minimal:8.6'
#      name: sonar-properties-create
#      resources: {}
#      script: >
#        #!/usr/bin/env bash
#
#        replaceValues() {
#          filename=$1
#          thekey=$2
#          newvalue=$3
#
#          if ! grep -R "^[#]*\s*${thekey}=.*" $filename >/dev/null; then
#            echo "APPENDING because '${thekey}' not found"
#            echo "" >>$filename
#            echo "$thekey=$newvalue" >>$filename
#          else
#            echo "SETTING because '${thekey}' found already"
#            sed -ir "s|^[#]*\s*${thekey}=.*|$thekey=$newvalue|" $filename
#          fi
#        }
#
#        if [[ -f $(workspaces.sonar-settings.path)/sonar-project.properties ]];
#        then
#          echo "using user provided sonar-project.properties file"
#          cp $(workspaces.sonar-settings.path)/sonar-project.properties $(workspaces.source-dir.path)/sonar-project.properties
#          ls -la $(workspaces.source-dir.path)
#        fi
#
#        if [[ -f $(workspaces.source-dir.path)/sonar-project.properties ]]; then
#          if [[ -n "$(params.SONAR_HOST_URL)" ]]; then
#            replaceValues $(workspaces.source-dir.path)/sonar-project.properties sonar.host.url $(params.SONAR_HOST_URL)
#          fi
#          if [[ -n "$(params.SONAR_PROJECT_KEY)" ]]; then
#            replaceValues $(workspaces.source-dir.path)/sonar-project.properties sonar.projectKey $(params.SONAR_PROJECT_KEY)
#          fi
#        else
#          touch sonar-project.properties
#          echo "sonar.projectKey=$(params.SONAR_PROJECT_KEY)" >> sonar-project.properties
#          echo "sonar.host.url=$(params.SONAR_HOST_URL)" >> sonar-project.properties
#          echo "sonar.sources=." >> sonar-project.properties
#        fi
#
#        echo "---------------------------"
#
#        cat $(workspaces.source-dir.path)/sonar-project.properties
#      workingDir: $(workspaces.source-dir.path)
#    - command:
#        - sonar-scanner
#      image: >-
#        docker.io/sonarsource/sonar-scanner-cli:latest
#      name: sonar-scan
#      resources: {}
#      workingDir: $(workspaces.source-dir.path)
#  workspaces:
#    - name: source-dir
#    - name: sonar-settings
#YAML
#}
#
#resource "kubectl_manifest" "jira_task" {
#  depends_on = [time_sleep.wait_120_seconds, kubernetes_namespace.demo-ci]
#  yaml_body = <<YAML
#apiVersion: tekton.dev/v1beta1
#kind: Task
#metadata:
#  name: send-to-jira
#  labels:
#    app.kubernetes.io/version: "1.0"
#  annotations:
#    tekton.dev/pipelines.minVersion: "0.12.1"
#spec:
#  description: These task creates issue in jira.
#  params:
#    - name: title
#      type: string
#      description: Title of issue
#    - name: project-key
#      type: string
#      description: A key of JIRA project
#    - name: token-secret-name
#      type: string
#      description: JIRA token
#    - name: username
#      type: string
#      description: JIRA login
#    - name: url
#      type: string
#      description: JIRA address
#    - name: content
#      type: string
#      description: JIRA description
#      default: ''
#  results:
#    - description: The issue id
#      name: issue-id
#  steps:
#    - name: post
#      image: docker.io/badouralix/curl-jq:latest
#      script: |
#        #!/bin/sh
#        JSON="{\"fields\":{\"project\":{\"key\":\"${PROJECT_KEY}\"},\"summary\":\"${TITLE}\",\"description\":\"${CONTENT}\",\"issuetype\":{\"name\":\"Task\"}}}"
#        echo $JSON | sed -e 's/\"/\\\\"/g'
#        curl -X POST -H 'Content-Type: application/json' -d "${JSON}" https://${URL}/rest/api/2/issue -u ${USERNAME}:${TOKEN} | jq .id -r | tee $(results.issue-id.path)
#      env:
#        - name: TOKEN
#          valueFrom:
#            secretKeyRef:
#              name: $(params.token-secret-name)
#              key: token
#        - name: USERNAME
#          value: $(params.username)
#        - name: URL
#          value: $(params.url)
#        - name: TITLE
#          value: $(params.title)
#        - name: PROJECT_KEY
#          value: $(params.project-key)
#        - name: CONTENT
#          value: $(params.content)
#  workspaces:
#    - name: source
#YAML
#}
#
#resource "kubectl_manifest" "pipeline" {
#  depends_on = [time_sleep.wait_120_seconds, kubernetes_namespace.demo-ci]
#  yaml_body = <<YAML
#apiVersion: tekton.dev/v1beta1
#kind: Pipeline
#metadata:
#  name: sample-kotlin-pipeline
#  namespace: pminkows-cicd
#spec:
#  params:
#    - description: branch
#      name: git-revision
#      type: string
#      default: s2i
#  tasks:
#    - name: git-clone
#      params:
#        - name: url
#          value: 'https://github.com/piomin/sample-spring-kotlin-microservice.git'
#        - name: revision
#          value: $(params.git-revision)
#        - name: sslVerify
#          value: 'false'
#      taskRef:
#        kind: ClusterTask
#        name: git-clone
#      workspaces:
#        - name: output
#          workspace: source-dir
#    - name: sonarqube
#      params:
#        - name: SONAR_HOST_URL
#          value: 'https://sonarcloud.io'
#        - name: SONAR_PROJECT_KEY
#          value: sample-spring-kotlin
#      runAfter:
#        - git-clone
#      taskRef:
#        kind: Task
#        name: sonarqube-scanner
#      workspaces:
#        - name: source-dir
#          workspace: source-dir
#        - name: sonar-settings
#          workspace: sonar-settings
#    - name: jira-issue
#      params:
#        - name: token-secret-name
#          value: jira-token-secret
#        - name: project-key
#          value: PIOM
#        - name: username
#          value: piotr.minkowski@gmail.com
#        - name: url
#          value: piotrminkowski.atlassian.net
#        - name: title
#          value: "1.0"
#      runAfter:
#        - sonarqube
#      taskRef:
#        kind: Task
#        name: send-to-jira
#      workspaces:
#        - name: source
#          workspace: source-dir
#    - name: s2i-java
#      params:
#        - name: TLSVERIFY
#          value: 'false'
#        - name: IMAGE
#          value: >-
#            quay.io/pminkows/sample-kotlin-spring:1.0
#      runAfter:
#        - jira-issue
#      taskRef:
#        kind: ClusterTask
#        name: s2i-java
#      workspaces:
#        - name: source
#          workspace: source-dir
#  workspaces:
#    - name: source-dir
#    - name: sonar-settings
#YAML
#}