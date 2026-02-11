#! /bin/bash

cd gitops
terraform init
terraform apply -auto-approve -var cluster-context=$(kubectx -c)