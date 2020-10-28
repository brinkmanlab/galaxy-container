output "endpoint" {
  value = kubernetes_service.galaxy_web.load_balancer_ingress.0.hostname
}

output "namespace" {
  value = local.namespace
}