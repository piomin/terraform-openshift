#! /bin/bash

terraform apply -auto-approve \
  -var cluster-context=default/api-z4g1r69s-eastus-aroapp-io:6443/kube:admin \
  -var sonar-token=${SONARQUBE_TOKEN} \
  -var github-token=${GITHUB_TOKEN} \
  -var argocd-token=${ARGOCD_TOKEN} \
  -var openshift-token=${OPENSHIFT_TOKEN} \
  -var github-client-secret=${GITHUB_CLIENT_SECRET} \
  -var azure-token=${AZURE_TOKEN}
  -var domain=${DOMAIN}