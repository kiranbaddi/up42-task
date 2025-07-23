resource "kubernetes_namespace" "s3www" {
  metadata {
    name = var.webapp_namespace
  }
}


resource "helm_release" "s3www" {
  name       = "s3www"
  namespace  = kubernetes_namespace.s3www.metadata[0].name
  create_namespace = false
  chart = "${path.module}/../s3www-app"
  version    = "1.0.0"
  values = [ 
    file("${path.module}/${var.environment}/s3www-helm-values.yaml")]
   set = [ 

   {
    name  = "image.tag"
    value = var.webapp_image_tag
  },
   {
    name  = "image.repository"
    value = var.webapp_image_repository
  },
  {
    name  = "bucket"
    value = var.minio_bucket
  },
  {
    name  = "environment"
    value = var.environment
  },
  {
    name  = "htmlContent"
    value = templatefile("${path.module}/${var.environment}/index.html", {
      environment = var.environment
    })
  }
]
set_sensitive = [
    {
    name  = "imagePullSecret.username"
    value = var.image_pull_secret_username
  },
  {
    name  = "imagePullSecret.password"
    value = var.image_pull_secret_password
  },
  {
    name  = "minio.credentials.accessKey"
    value = var.minio_access_key
  },
  {
    name  = "minio.credentials.secretKey"
    value = var.minio_secret_key
  }
  ]
  depends_on = [
    helm_release.nginx_ingress, kubernetes_namespace.s3www, kubernetes_job.minio_file_upload_job ] 

}

