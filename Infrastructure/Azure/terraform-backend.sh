#!/bin/bash

set -e

RESOURCE_GROUP="up42"
STORAGE_ACCOUNT_NAME="up42tfstate"
CONTAINER_NAME="tfstate"   


# Check if the resource group exists
if ! az group exists --name $RESOURCE_GROUP; then
    echo "Creating resource group: $RESOURCE_GROUP"
    az group create --name $RESOURCE_GROUP --location eastus
else
    echo "Resource group $RESOURCE_GROUP already exists."
fi  


# Check if the storage account exists
if ! az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP &> /dev/null; then
    echo "Creating storage account: $STORAGE_ACCOUNT_NAME"
    az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --sku Standard_LRS --encryption-services blob
else
    echo "Storage account $STORAGE_ACCOUNT_NAME already exists."
fi          

# Check if the container exists
if ! az storage container show --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME &> /dev/null; then
    echo "Creating storage container: $CONTAINER_NAME"
    az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
else
    echo "Storage container $CONTAINER_NAME already exists."
fi  


