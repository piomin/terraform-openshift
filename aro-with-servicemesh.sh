#! /bin/bash

echo "Type your guid: "
read guid

cd aro
terraform init
terraform apply -auto-approve -var guid=$guid
domain="apps.$(terraform output -raw domain).eastus.aroapp.io"

cd ../servicemesh
terraform init
terraform apply -auto-approve -var kubeconfig=../aro/kubeconfig -var domain=$domain