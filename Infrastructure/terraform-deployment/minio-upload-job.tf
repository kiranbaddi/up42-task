# Alternative approach using Kubernetes Job with ConfigMap
resource "kubernetes_config_map" "html_file" {
  metadata {
    name      = "html-file"
    namespace = kubernetes_namespace.minio.metadata[0].name
  }

  data = {
    "index.html" = file("${path.module}/${var.environment}/index.html")
  }
}

resource "kubernetes_job" "minio_file_upload_job" {
  count = 1

  depends_on = [helm_release.minio, kubernetes_config_map.html_file]

  metadata {
    name      = "minio-file-upload"
    namespace = kubernetes_namespace.minio.metadata[0].name
  }

  spec {
    template {
      metadata {}
      spec {
        restart_policy = "Never"

        container {
          name  = "minio-uploader"
          image = "minio/mc:latest"

          command = ["/bin/sh"]
          args = [
            "-c",
            <<-EOT
              sleep 30s

              # Configure MinIO client
              mc alias set internal http://minio.${kubernetes_namespace.minio.metadata[0].name}.svc.cluster.local:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD

              # Create bucket if it doesn't exist
              mc mb internal/${var.minio_bucket} --ignore-existing

              # Upload the file
              mc cp /data/index.html internal/${var.minio_bucket}/

              # Verify upload
              mc ls internal/${var.minio_bucket}/index.html

              echo "File uploaded successfully to MinIO"
            EOT
          ]

          env {
            name = "MINIO_ROOT_USER"
            value_from {
              secret_key_ref {
                name = "minio"
                key  = "root-user"
              }
            }
          }

          env {
            name = "MINIO_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "minio"
                key  = "root-password"
              }
            }
          }

          volume_mount {
            name       = "data-volume"
            mount_path = "/data"
            read_only  = true
          }
        }

        volume {
          name = "data-volume"
          config_map {
            name = kubernetes_config_map.html_file.metadata[0].name
          }
        }
      }
    }

    backoff_limit = 3
  }

  wait_for_completion = true
  timeouts {
    create = "5m"
    update = "5m"
  }
}
