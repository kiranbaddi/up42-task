#!/bin/bash

set -e
ENVIRONMENT=$1
if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 [development|staging|production]"
    exit 1
fi

KEYVAULT_NAME="up42-kv-$ENVIRONMENT"
RESOURCE_GROUP="up42"
LOCATION="westeurope"
MINIO_SECRET_KEY=$(openssl rand -base64 22)

## Check if the Key Vault already exists, if not create it
if az keyvault show --name $KEYVAULT_NAME &> /dev/null; then
    echo "Azure Key Vault $KEYVAULT_NAME already exists."
else
    az keyvault create --name $KEYVAULT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --sku standard

    echo "Created Azure Key Vault: $KEYVAULT_NAME"
fi

# Create secrets in the Key Vault
az keyvault secret set --vault-name $KEYVAULT_NAME --name minio-access-key --value "minio-dev" --output none
az keyvault secret set --vault-name $KEYVAULT_NAME --name minio-secret-key --value "$MINIO_SECRET_KEY" --output none

