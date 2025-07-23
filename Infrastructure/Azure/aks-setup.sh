#! /bin/bash

set -e

RESOURCE_GROUP="up42"
CLUSTER_NAME="up42-aks"
# Check if the resource group exists
if ! az group exists --name $RESOURCE_GROUP; then
    echo "Creating resource group: $RESOURCE_GROUP"
    az group create --name $RESOURCE_GROUP --location eastus
else
    echo "Resource group $RESOURCE_GROUP already exists."
fi  
# Check if the AKS cluster exists
if ! az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME &> /dev/null; then
    echo "Creating AKS cluster: $CLUSTER_NAME"
    az aks create --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --node-count 3 --enable-addons monitoring --generate-ssh-keys --kubernetes-version 1.33.1 --node-vm-size Standard_B2s --network-plugin azure --network-policy azure
else
    echo "AKS cluster $CLUSTER_NAME already exists."
fi  

# Get the credentials for the AKS cluster
echo "Getting credentials for AKS cluster: $CLUSTER_NAME"
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite
# Check if the Azure File CSI driver is installed
if ! kubectl get storageclass azurefile-csi &> /dev/null; then
    echo "Installing Azure File CSI driver"
    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/main/deploy/azurefile-csi-driver.yaml
else
    echo "Azure File CSI driver already installed."
fi