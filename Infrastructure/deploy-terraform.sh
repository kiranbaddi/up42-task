#!/bin/bash

ENVIRONMENT=$1
if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 [development|staging|production]"
    exit 1
fi

ACR_NAME="s3wwwapp"
K8s_CLUSTER_NAME="up42-aks"
RESOURCE_GROUP="up42"
KEYVAULT_NAME="up42-kv-$ENVIRONMENT"

az aks get-credentials --resource-group $RESOURCE_GROUP --name $K8s_CLUSTER_NAME --file /tmp/aks-config.yaml
export KUBECONFIG=/tmp/aks-config.yaml

# Get Azure service principal credentials
PASSWORD=$(az ad sp create-for-rbac --name "K8s-sp" --scopes $(az acr show --name $ACR_NAME --query "id" --output tsv) --role acrpull --query "password" --output tsv)
USER_NAME=$(az ad sp list --display-name "K8s-sp" --query "[].appId" --output tsv)

# Get MinIO credentials from Key Vault
MINIO_ACCESS_KEY=$(az keyvault secret show --name minio-access-key --vault-name $KEYVAULT_NAME --query "value" --output tsv)
MINIO_SECRET_KEY=$(az keyvault secret show --name minio-secret-key --vault-name $KEYVAULT_NAME --query "value" --output tsv)

# Set Terraform variables
export TF_VAR_environment=$ENVIRONMENT
export TF_VAR_minio_namespace="minio"

# Set individual variables
export TF_VAR_webapp_enabled=true
export TF_VAR_webapp_namespace="webapp"
export TF_VAR_webapp_image_repository="s3wwwapp.azurecr.io/s3www"
export TF_VAR_webapp_image_tag="1.0.0"
export TF_VAR_image_pull_secret_username="$USER_NAME"
export TF_VAR_image_pull_secret_password="$PASSWORD"
export TF_VAR_minio_access_key="$MINIO_ACCESS_KEY"
export TF_VAR_minio_secret_key="$MINIO_SECRET_KEY"
export TF_VAR_nginx_ingress_enabled=true


cd terraform-deployment
terraform init -upgrade
terraform workspace select $ENVIRONMENT || terraform workspace new $ENVIRONMENT
terraform plan -out=tfplan 
terraform apply -auto-approve



rm -rf /tmp/aks-config.yaml
if [ $? -ne 0 ]; then
    echo "Terraform apply failed. Please check the logs."
    exit 1
else
    echo "Terraform apply completed successfully."
    echo "Deployment for $ENVIRONMENT environment is complete."
    echo "You can access the application at http://up42.$ENVIRONMENT.devopsgym.com"
fi
