#!/bin/bash

terraform -chdir="./workloads/jupyterhub/" init 
terraform -chdir="./workloads/" init 
terraform -chdir="./platform/" init

export CLUSTERNAME=$(cat ./platform/platform.auto.tfvars | grep -w cluster_name | awk {'print $NF'}| awk -F'["]' '{ print $2 }')
export REGION=$(cat ./platform/platform.auto.tfvars | grep -w cluster_region | awk {'print $NF'}| awk -F'["]' '{ print $2 }')
export PROJECT=$(cat ./platform/platform.auto.tfvars | grep -w project_id | awk {'print $NF'} | awk -F'["]' '{ print $2 }')

export KUBE_CONFIG_PATH=~/.kube/config 
gcloud container clusters get-credentials $CLUSTERNAME --region $REGION --project $PROJECT 

echo -e "################"
echo -e "JUPYTERHUB DELETE"
echo -e "################"
terraform -chdir="./workloads/jupyterhub/" destroy -auto-approve


echo -e "################"
echo -e "USER DELETE"
echo -e "################"
terraform -chdir="./workloads/" destroy -auto-approve


echo -e "################"
echo -e "PLATFORM DELETE	"
echo -e "################"
terraform -chdir="./platform/" destroy -auto-approve
