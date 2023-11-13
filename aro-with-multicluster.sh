#! /bin/bash

echo "Type your guid: "
read guid

cd aro
terraform init
terraform apply -auto-approve -var guid=$guid

cd ../multicluster
terraform init
terraform apply -auto-approve -var kubeconfig=../aro/kubeconfig