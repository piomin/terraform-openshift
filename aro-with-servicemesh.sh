#! /bin/bash

cd aro
terraform init
terraform apply -auto-approve

cd ../servicemesh
terraform init
terraform apply -auto-approve -var kubeconfig=../aro/kubeconfig