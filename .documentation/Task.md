# Senior Cloud Engineer Challenge
We're excited you've reached this stage in our hiring process for the Senior Cloud
Engineer role. This challenge is designed to give you an opportunity to showcase your
skills in designing and implementing robust deployment solutions, mirroring the kind
of work you'd do at UP42.
Overview
As a Senior Cloud Engineer in the SRE team at UP42, a key responsibility is enabling
development teams by providing reliable and efficient ways to deploy their
applications. We heavily utilize Kubernetes, and a common pattern involves creating
Helm charts to manage application resources.
This challenge involves setting up a local Kubernetes deployment for a sample
application using Helm and Terraform, focusing on creating a solution that embodies
production best practices. We recommend using a local Minikube cluster or
Kubernetes on Docker Desktop.
We estimate this challenge should take approximately 4 hours to complete. This
timeframe is intended to respect your time while providing sufficient scope to
demonstrate your approach to building production-ready systems.

## The Challenge
Your goal is to design and implement a deployment for the s3www application and its
dependency, MinIO, using Helm and Terraform.

## Resources
 -  Application: s3www - A small Go-based web server for serving files from S3-compatible storage.
 -  Dependency: MinIO - An S3-compatible object storage solution, used here for local storage.
 -  Content: File to serve - The application should serve this file once deployed.

## Helm Chart Requirements

You will provide Helm chart(s) to deploy the s3www application and its MinIO
dependency. 

 -  The chart(s) must manage the deployment of both s3www and MinIO services.
 -  Implement a mechanism within the chart to automatically fetch the "File to serve" and place it into the MinIO bucket upon startup.
 -  Anticipate future needs: The s3www application will eventually expose Prometheus metrics. Ensure your configuration allows a Prometheus Operator (assumed to be present in the cluster) to automatically discover these metrics.
 -  The chart(s) should be structured and configured adhering to best practices,
making them suitable for reuse in a production environment.
 -  Include configuration for accessing the s3www application from outside the cluster (e.g., via a LoadBalancer service or an Ingress resource).

## Terraform Infrastructure as Code Requirements

You will provide Terraform code to define and manage the application's deployment
infrastructure.

 -  The Terraform configuration should orchestrate the deployment of the application and its dependencies onto the Kubernetes cluster. Consider how Terraform can manage the full lifecycle of the deployment.
 -  The code should be designed with reusability, maintainability, and production standards in mind, representing how you would manage infrastructure in a real-world scenario.
## Crucial Documentation
Clear and comprehensive documentation is paramount for any production system. We
place significant emphasis on your ability to communicate your design and
implementation effectively.
 
 -  README.md: Provide thorough documentation detailing your solution. This should enable another engineer to understand the architecture, deployment process, configuration options, and operational considerations necessary to use and maintain this system in a production setting. 

 -  CHALLENGE.md: This file is your space to articulate your thought process. Discuss design decisions, potential trade-offs you considered, any concerns you
have about the implementation (e.g., limitations, security aspects), its strengths and weaknesses, and any other insights relevant to deploying and operating such an application. This helps us understand how you approach technical challenges and evaluate solutions.

## Handover Format

Please submit your solution as a link to a git repository (e.g., on GitHub, GitLab) or as a .zip archive containing the complete .git history. Ensure your commit history reflects
your development process. 

## Challenge Assessment

We will evaluate your submission holistically, focusing on the qualities expected of a
Senior Cloud Engineer. This includes:

 -  Solution Quality: Assessing the overall robustness, maintainability, and operational readiness of your implementation (Helm chart, Terraform code, automation).
 -  Best Practices: Evaluating adherence to established patterns and practices for Kubernetes, Helm, Terraform, and general system design suitable for production environments.
 -  Clarity and Communication: Reviewing the comprehensiveness and clarity of your README.md documentation and the depth of insight provided in your CHALLENGE.md.

We are looking for a well-reasoned solution that demonstrates a strong understanding of building, deploying, and documenting production-grade cloud infrastructure.


