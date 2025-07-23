#!/bin/bash
set -e


ACR_NAME="s3wwwapp"
# Check if the ACR already exists if not create create
if ! az acr show --name $ACR_NAME &> /dev/null; then
    echo "Creating Azure Container Registry: $ACR_NAME"
    az acr create --resource-group up42 --name $ACR_NAME --sku Basic --admin-enabled true
else
    echo "Azure Container Registry $ACR_NAME already exists."
fi

ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query "id" --output tsv)
SERVICE_PRINCIPAL_NAME="K8s-sp"
PASSWORD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role acrpull --query "password" --output tsv)
USER_NAME=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" --output tsv)
SERVICE_PRINCIPAL_ID=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].id" --output tsv)


az acr login --name $ACR_NAME

docker push s3wwwapp.azurecr.io/s3www:1.0.0

az role assignment create --assignee $SERVICE_PRINCIPAL_ID --scope $ACR_REGISTRY_ID --role acrpull

kubectl delete secret s3www-image-pull-secret --ignore-not-found
kubectl create secret docker-registry s3www-image-pull-secret \
    --namespace default \
    --docker-server=$ACR_NAME.azurecr.io \
    --docker-username=$USER_NAME \
    --docker-password=$PASSWORD