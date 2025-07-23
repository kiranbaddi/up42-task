# Kubernetes namespace for nginx conroller
resource "kubernetes_namespace" "nginx_ingress_namespace" {
  count = var.nginx_ingress_namespace == "default" ? 0 : 1
  metadata {
    name = var.nginx_ingress_namespace
    labels = {
      "kubernetes.io/metadata.name" = var.nginx_ingress_namespace
      "k8s-app"                     = "nginx-ingress"
    }
  }
}

resource "helm_release" "nginx_ingress" {
  count            = var.nginx_ingress_enabled ? 1 : 0
  name             = "nginx"
  namespace        = var.nginx_ingress_namespace
  repository       = "https://helm.nginx.com/stable"
  chart            = "nginx-ingress"
  create_namespace = true

  values = [
    yamlencode({
      controller = {
        service = {
          type = var.nginx_ingress_service_type
        }
        ingressClass = {
          name = "nginx"
        }
        setAsDefaultIngress = true
      }
    })
  ]
}

