variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

}

variable "nginx_ingress_enabled" {
  description = "Enable NGINX Ingress Controller"
  type        = bool
  default     = false
}

variable "nginx_ingress_namespace" {
  description = "Namespace for NGINX Ingress Controller"
  type        = string
  default     = "nginx-ingress"

}


variable "nginx_ingress_service_type" {
  description = "Service type for NGINX Ingress Controller"
  type        = string
  default     = "LoadBalancer"

}

variable "webapp_enabled" {
  description = "Enable web application"
  type        = bool
  default     = true
}

variable "webapp_namespace" {
  description = "Namespace for web application"
  type        = string
  default     = "webapp"
}

variable "webapp_image_repository" {
  description = "Web application image repository"
  type        = string
  default     = "s3wwwapp.azurecr.io/s3www"
}

variable "webapp_image_tag" {
  description = "Web application image tag"
  type        = string
  default     = "1.0.0"
}

variable "image_pull_secret_username" {
  description = "Image pull secret username"
  type        = string
  sensitive   = true
}

variable "image_pull_secret_password" {
  description = "Image pull secret password"
  type        = string
  sensitive   = true
}

variable "minio_access_key" {
  description = "MinIO access key"
  type        = string
  sensitive   = true
}

variable "minio_secret_key" {
  description = "MinIO secret key"
  type        = string
  sensitive   = true
}

variable "minio_namespace" {
  description = "Namespace for MinIO"
  type        = string
  default     = "minio"
}

variable "minio_bucket" {
  description = "MinIO bucket name"
  type        = string
  default     = "up42"

}