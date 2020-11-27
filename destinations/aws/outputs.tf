output "endpoint" {
  value = module.k8s.endpoint
}

output "smtp_conf" {
  value = local.smtp_conf
}

output "nfs_server" {
  value = module.nfs_server.nfs_server
}

output "namespace" {
  value = module.k8s.namespace
}