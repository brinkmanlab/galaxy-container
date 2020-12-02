output "endpoint" {
  value = module.k8s.endpoint
}

output "smtp_conf" {
  value = local.smtp_conf
}

output "nfs_server" {
  value = length(module.nfs_server) > 0 ? module.nfs_server[0].nfs_server : null
}

output "namespace" {
  value = module.k8s.namespace
}