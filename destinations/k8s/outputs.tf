output "endpoint" {
  value = kubernetes_ingress.galaxy_web.status.0.load_balancer.0.ingress.0.hostname
}

output "namespace" {
  value = local.namespace
}