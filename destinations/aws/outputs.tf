output "endpoint" {
  value = module.k8s.endpoint
}

output "smtp_conf" {
  value = local.smtp_conf
  description = "galaxy_conf must have email_from configured for this to not be empty"
}

output "nfs_server" {
  value = length(module.nfs_server) > 0 ? module.nfs_server[0].nfs_server : null
}

output "namespace" {
  value = module.k8s.namespace
}