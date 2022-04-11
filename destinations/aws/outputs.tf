output "endpoint" {
  value = module.k8s.endpoint
  description = "Galaxy front-end HTTP endpoint"
}

output "smtp_conf" {
  value       = local.smtp_conf
  description = "galaxy_conf must have email_from configured for this to not be empty"
}

output "nfs_server" {
  value = length(module.nfs_server) > 0 ? module.nfs_server[0].nfs_server : null
  description = "AWS EFS domain name mounted by Galaxy"
}

output "namespace" {
  value = module.k8s.namespace
  description = "Kubernetes namespace containing Galaxy resources"
}