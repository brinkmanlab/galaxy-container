output "eks" {
  value = local.cloud.eks
}

output "vpc" {
  value = local.cloud.vpc
}

output "efs_user_data" {
  value = aws_efs_file_system.user_data.dns_name
}

output "endpoint" {
  value = module.galaxy-k8s.endpoint
}

output "smtp_conf" {
  value = local.smtp_conf
}

output "nfs_server" {
  value = aws_efs_file_system.user_data.dns_name
}