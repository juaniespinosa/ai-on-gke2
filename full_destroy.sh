#!/bin/bash


export CLUSTERNAME=$(terraform -chdir="./platform/" output -raw cluster-name)
export REGION=$(terraform -chdir="./platform/" output -raw region)
export PROJECT=$(terraform -chdir="./platform/" output -raw project)

export KUBE_CONFIG_PATH=~/.kube/config 
gcloud container clusters get-credentials $CLUSTERNAME --region $REGION --project $PROJECT 

echo -e "################"
echo -e "JUPYTERHUB"
echo -e "################"
terraform -chdir="./workloads/jupyterhub/" destroy -auto-approve


echo -e "################"
echo -e "USER"
echo -e "################"
terraform -chdir="./workloads/" destroy -auto-approve


echo -e "################"
echo -e "PLATFORM	"
echo -e "################"
terraform -chdir="./platform/" destroy -auto-approve
