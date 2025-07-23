## Local Development

- [X] Install the application locally and test it with S3 for quick feedback
- [X] Containerize the applicaiton  
- [X] Write a Docker-compose file running the application and minio in the same network the for faster iteratino
- [X] Create Kubernetes Manifests for the application and deploy locally on kind cluster
- [X] Create Helm chart.
- [X] Create Terraform Configuration for the helm chart.

## Production Deployment

- [X] Use Azure bucket for remote backent. 
- [ ] Create a self signed certificate with let's encrypt
- [X] Create Vault for secrets or use Azure Key Vault 
- [X] Deploy to Azure Kuberntes Service
- [ ] Create GitHub Actions workflow to deploy to multiple namespaces within the same cluster

> **🤖AI Usage:** I have leveraged Copilot when refactoring code - mutliple values replacements or changing the value in multiple values files as well as validating yaml and writting shell scripts.

## Development

- Uploaded a basic [index.html](../Infrastructure/index.html) file to a S3 bucket
- Built the application

    ```bash
    cd s3wwww
    go build
    ```

- Test the application locally with the file in S3 bucket

    ```bash
    cd s3www
    ./s3www -endpoint $S3_ENDPOINT \
            -bucket $S3_BUCKET \
            -accessKey $AWS_ACCESS_KEY_ID \
            -secretKey $AWS_SECRET_ACCESS_KEY
    ```

- Create and test Docker Image with existing Dockerfile.
    
    ```bash
    docker build . -t kiranbaddi/s3awww:1.0.0
    ```

Building the docker container with the existing Dockerfile didn't work. 
Couple of issues:
1. Since Scratch is too minimal difficult to debug the issue. 
2. s3www was not recognized. 

Solution:
Tried building the Docker Container but by using golang:1.21-alpine, I still encountered the error 
`-endpoint: line 0: /s3www: not found`. Created an image with CMD instead of Entrypoint to debug and try to run s3www from inside the container but stil the same issue. I used golang:1.21-bookworm and the application worked perfectly. 

When I asked Copilot what's causing the error in alpine image, the Dockerfile is copying pre-built s3www and it's not built on the glibc that Alpine uses. Hence the suggestion was to build with a golang image with proper flags for Alpine such as CGO_ENABLED=0 and GOOS=linux. 

The docker image is not as slim as the one with Scratch but we have a fully functioning image with golang:1.24-alpine 💯

- Build docker container and storing it in Azure Container registry (as I plan to deploy the final helm chart with Terraform in AKS). 

- Created Manifests for local testing before creating helm charts with them. 

- Created a small script ot create ACR container and create a Kuberentes secret to pull images (for local deployment only)

- Alternatively I could have used Dockerhub for containers but I want to use fewere providers as possible .

- Tried creating a k8s job but it has taken longer than expected to mount a local directory as a Volume mount on Kind cluster. As we deploy the Helm chart with Terraform, I plan to use terraform templating to pass the file to th4e kuberentes job to upload to Minio bucket. 



### Storage Class

Already created a storage class and when creating the stroageClass as part of the helm chart it throws the error that existing Storage Class is not managed by Helm. Disabled Storage class from custom values file.

### Namespace

Helm release often breaks because there is no main Release and the webapp namespace is not created before the deployment of the webapp itself. 

Hence decided to use official minio helm chart and a stand-alone job in terraform deployment and just limit the chart to s3www resources only. 

Experienced issues in using namespace template within the helm chart for s3www the namespace is not created before the deployment is deployed and clean up was a mess. Hence created namespace out of the helm chart with Kubernetes resource.

### Secrets

Helm chart creates image pull secret as well as the minio credentials. Minio Credentails uses the same access_key and secret_key values that are used in minio helm chart 

### Ingress Controller

Ingress controller - Used nginx ingress controller as it's the simplest and meets the use case for this application. 
I used a hostname called http://up42.devopsgym.com as I have devopsgym.com reistered with me. The application is accessible at http://up42.devopsgym.com

### Remote backend

Used Azure object storagge container to  store the terraform state. I'd use a Terraform Cloud workspace for better RBAC and centralized state for all deployments in a Production grade scenario. 



## Trade-offs and Alternative considerations

1. Minio could be deployed outside the helm chart to ensure the chart is minimal and consists only the application and it's allied resources such as service, ingress etc. 

   - **Alternative #1** - Add minio as a dependent chart 

     Chart.yaml

     ```yaml
     apiVersion: v2
     name: s3www
     description: A Helm chart for deploying S3WWW application.
     type: application
     version: 1.0.0
     appVersion: "1.0.0"

     dependencies:
       - name: minio
         version: "14.7.5"
         repository: "https://charts.bitnami.com/bitnami"
     ```

     ```values.yaml
     # s3www chart values
     minio:
       replicaCount: 3
     ```

   - **Alternative #2** - Install Minio helm chart and Minio Job as separate resources using Terraform.

2. Image Pull Secret is created within the helm chart. This can be outside the chart as it's more of an Infrastrructure resource.
   Also the `.dockerconfigjson` can be stored inside KeyVault rather than creating PASSWORD for every deployment.

   Followed this approach to deploy Minio using Bitnami helm chart with Terraform. As this would handle 

3. Job to upload file. I have created a Kubernetes job to upload the file using the File template with Terraform. Alternatively I could use a initContainer inside the s3www application but that would not be very flexible for the application to use file from a different storage system. 
   This could have been done with a local or remove provisioner in terraform. 

   Passing complex html (with css) is an issue in the current setup with configMap. mounting the file as volume and making it avai





## To-DO

- [ ] Install Cert manager and Let's encrpt issuer to get a self signed certificate for the domain name.

- [ ] Create a GitHub Actions workflow to apply Terraform from GitHub actions. (is work in progress. Currently failing at retrieving secrets from KV)