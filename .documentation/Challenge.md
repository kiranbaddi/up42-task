## Local Development

- [ ] Install the application locally and test it with S3 for quick feedback
- [ ] Containerize the applicaiton  
- [ ] Write a Docker-compose file running the application and minio in the same network the for faster iteratino
- [ ] Create Kubernetes Manifests for the application and deploy locally on kind cluster
- [ ] Create Helm chart.
- [ ] Create Terraform Configuration for the helm chart.

## Production Deployment 
- [ ] Use Azure bucket for remote backent. 
- [ ] Create a self signed certificate with let's encrypt
- [ ] Create Vault for secrets or use Azure Key Vault 
- [ ] Deploy to Azure Kuberntes Service
- [ ] Create GitHub Actions workflow to deploy to multiple namespaces within the same cluster



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