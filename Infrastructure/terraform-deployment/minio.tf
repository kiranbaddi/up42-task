resource "kubernetes_namespace" "minio" {
  metadata {
    name = "minio"
  }
}

resource "helm_release" "minio" {
  name       = "minio"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "minio"
  version    = "14.7.5"

  namespace        = kubernetes_namespace.minio.metadata[0].name
  create_namespace = true

  values = [
    file("${path.module}/${var.environment}/minio-values.yaml")
  ]

  set_sensitive = [
    {
      name  = "auth.rootUser"
      value = var.minio_access_key
    },
    {
      name  = "auth.rootPassword"
      value = var.minio_secret_key
    }
  ]

  depends_on = [kubernetes_namespace.minio]
}

