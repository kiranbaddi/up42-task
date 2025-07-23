# UP42 Task

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat&logo=helm&logoColor=white)](https://helm.sh/)
[![Azure](https://img.shields.io/badge/Azure-0078D4?style=flat&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![Terraform](https://img.shields.io/badge/Terraform-623CE4?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)

## Table of Contents

- [Summary](#summary)
- [Prerequisites](#prerequisites)
- [Deployment](#deployment)
- [Terraform](#terraform)
- [Helm Chart](#helm-chart)


## Summary

This project creates minio server and a bucket with a static html file and s3www app that uses the html file to serve the content. 
The deployment aims to create resources in Azure Kubernetes Service (AKS) and retrieves secrets from Key Vault.

## Prerequisites

- Go
- Terraform
- Kubectl 
- Kind for local development
- Helm
- Docker & Docker Compose for local development
- Azure CLI for faster provisioning of Azure Resources


## Deployment

1. Update values.yaml in the respective environment ex: [values for development](./Infrastructure/terraform-deployment/development/s3www-helm-values.yaml) 

2. Create Key Vault for respective environment and update minio-access-key minio-secret-key. Refer [Azure KeyVault Setup](#azure-key-vault-setup)

3. Execute the following command

   ```bash
   Infrastructure/deploy-terraform.sh <environment>
   ```

## Helm Chart

The helm chart deploys the following resources 

- Namespace for the application (webapp)
- Kubernetes deployment for webapp
- Kubernetes service for webapp 
- Kuberntes ingress for webapp

## Terraform

- Terraform configuration uses helm and kuberntetes providers with Azure bucket as remote backend.
- [Deployment script](./Infrastructure/deploy-terraform.sh) to create terraform in a desired environment.
- Terraform provisions 
  - nginx-ingress-controller helm chart 
  - s3www-app
  - minio helm chart
  - minio client job to create a bucket and upload a file.

  ```bash
  cd ./Infrastructure
  bash ./deploy-terraform.sh
  ```

- The deployment uses the values file in individual directory for each environment ex: [values for development](./Infrastructure/terraform-deployment/development/s3www-helm-values.yaml)
- Infrastructure related values such as Resources' limits and requests are not often changed hence this can be retrieved from values file with individual environment values file.
- For this task I am retrieving the index.html from the respective environment file. 

## Local Deployment

- The application along with mino and minio client job can be tested with the [Docker Compose](./s3www/docker-compose.yml).
- Docker compose file builds the docker container for the application using [Dockerfile](./s3www/Dockerfile)

## Appendix 

### Go Installation

```bash
curl -LO https://go.dev/dl/go1.24.5.linux-amd64.tar.gz 
sudo tar -C /usr/local -xzf go1.24.5.linux-amd64.tar.gz  
export PATH=$PATH:/usr/local/go/bin
```

### Minio Client Installation

```bash
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc

chmod +x $HOME/minio-binaries/mc
export PATH=$PATH:$HOME/minio-binaries/

mc --help
```

```bash
mc alias set myminio http://minio.svc.cluster.local:9000
```


### Azure Key Vault Setup

Assign the user executing the script the "Key Vault Secrets Officer"

```bash
az role assignment create \
  --assignee <user-id> \
  --role "Key Vault Secrets Officer" \
  --scope "/subscriptions/<subscriptionId/resourceGroups/up42/providers/Microsoft.KeyVault/vaults/<keyVaultName>"
```

- Use [Keyvault Setup Script ](./Infrastructure/Azure/az-keyvault-setup.sh) to create KeyVault for a particular environment. 