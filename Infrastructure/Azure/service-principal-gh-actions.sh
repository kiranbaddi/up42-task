#!/bin/bash

# --- Configuration ---
# You can change these variables
RESOURCE_GROUP_NAME="up42"
ACR_NAME="s3wwwapp"             
KEYVAULT_NAME="up42-kv"         
SP_NAME="aks-ci-cd-sp"

# --- Get current subscription and tenant details ---
CURRENT_SUB_ID=$(az account show --query id -o tsv)
CURRENT_TENANT_ID=$(az account show --query tenantId -o tsv)

if [ -z "$CURRENT_SUB_ID" ] || [ -z "$CURRENT_TENANT_ID" ]; then
    echo "Error: Could not retrieve current subscription or tenant ID. Please log in to Azure CLI."
    exit 1
fi

echo "Current Subscription ID: $CURRENT_SUB_ID"
echo "Current Tenant ID: $CURRENT_TENANT_ID"
echo ""

# --- Create Service Principal ---
echo "Creating Azure Service Principal: $SP_NAME..."
# Using --json output to easily parse the results for the AZURE_CREDENTIALS
sp_output_json=$(az ad sp create-for-rbac --name "$SP_NAME" --role "contributor" --scopes "/subscriptions/$CURRENT_SUB_ID" --query '{appId: appId, password: password}' -o json)

if [ -z "$sp_output_json" ]; then
    echo "Error: Failed to create Service Principal. Exiting."
    exit 1
fi

SP_APP_ID=$(echo "$sp_output_json" | jq -r '.appId')
SP_PASSWORD=$(echo "$sp_output_json" | jq -r '.password')
SP_OBJECT_ID=$(az ad sp show --id "$SP_APP_ID" --query id -o tsv)


echo "Service Principal '$SP_NAME' created successfully."
echo "App ID (Client ID): $SP_APP_ID"
echo "Client Secret (Password): $SP_PASSWORD"
echo "Object ID: $SP_OBJECT_ID"
echo "--- IMPORTANT: Store the Client Secret securely. Do not expose it. ---"
echo ""

# --- Assign ACR Pull Rights ---
echo "Assigning 'AcrPull' role to $ACR_NAME for Service Principal..."
az role assignment create --assignee "$SP_APP_ID" --role "AcrPull" --scope "/subscriptions/$CURRENT_SUB_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME"

echo "AcrPull role assigned."
echo ""

# --- Assign Key Vault Officer Rights ---
echo "Assigning 'Key Vault Officer' role to $KEYVAULT_NAME for Service Principal..."
az role assignment create --assignee "$SP_APP_ID" --role "Key Vault Secrets Officer" --scope "/subscriptions/$CURRENT_SUB_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.KeyVault/vaults/$KEYVAULT_NAME"

echo "Key Vault Officer role assigned."
echo ""

# --- Assign AKS Management Rights (Subscription Level) ---
# This role allows managing Kubernetes deployments at a cluster level for all clusters in the subscription.
# Be aware this is a broad permission. Consider scoping to specific resource groups if possible.
echo "Assigning 'Azure Kubernetes Service Cluster Admin Role' at subscription level for Service Principal..."
az role assignment create --assignee "$SP_APP_ID" --role "Azure Kubernetes Service Cluster Admin Role" --scope "/subscriptions/$CURRENT_SUB_ID"

echo "Azure Kubernetes Service Cluster Admin Role assigned at subscription level."
echo ""

# --- Generate AZURE_CREDENTIALS for GitHub Actions ---
echo "Generating AZURE_CREDENTIALS JSON for GitHub Actions..."

AZURE_CREDENTIALS_JSON=$(cat <<EOF
{
  "clientId": "$SP_APP_ID",
  "clientSecret": "$SP_PASSWORD",
  "tenantId": "$CURRENT_TENANT_ID",
  "subscriptionId": "$CURRENT_SUB_ID"
}
EOF
)

echo "--- Copy the following JSON and add it as a GitHub Actions Secret named AZURE_CREDENTIALS ---"
echo "Make sure to escape any special characters if pasting directly into a CI/CD variable editor."
echo ""
echo "$AZURE_CREDENTIALS_JSON"
echo ""
echo "--- END AZURE_CREDENTIALS ---"
echo ""

echo "Service Principal setup complete."
echo "You can now use this Service Principal to:"
echo "  - Build and push images to Azure Container Registry ($ACR_NAME)."
echo "  - Perform helm installs and manage deployments on AKS clusters in this subscription."
echo "  - Read and update secrets in Azure Key Vault ($KEYVAULT_NAME)."