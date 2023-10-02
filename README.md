# OpenShift with Terraform Configuration [![Twitter](https://img.shields.io/twitter/follow/piotr_minkowski.svg?style=social&logo=twitter&label=Follow%20Me)](https://twitter.com/piotr_minkowski)

[![CircleCI](https://circleci.com/gh/piomin/sample-spring-microservices-new.svg?style=svg)](https://circleci.com/gh/piomin/sample-spring-microservices-new)

In this project I'm demonstrating how to use Terraform to create and manage OpenShift clusters.

## Description 

Here's the list of articles that explain in the details how it works:
1. How to create OpenShift cluster on Azure with the ARO managed service and install operators and apps: [Manage OpenShift with Terraform](https://piotrminkowski.com/2023/09/29/manage-openshift-with-terraform/)

## Getting Started

You need to install Azure CLI (`az`) and Terraform CLI.

First login to the Azure account. You need an account there:
```shell
$ az account show
```

Then just run my script on the existing AZ resource group:
```shell
$ ./aro-with-servicemesh.sh
```

### Scenarios

#### Multicluster

Go to the `multicluster` directory. Run the following command to initialize workspace:
```shell
$ terraform init
```

Then, let's create required objects:
```shell
$ terraform apply -auto-approve -var kubeconfig=../aro/kubeconfig
```