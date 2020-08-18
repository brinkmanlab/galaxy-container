output "eks" {
  value = module.eks
}

output "vpc" {
  value = module.vpc
}

output "efs_user_data" {
  value = aws_efs_file_system.user_data.dns_name
}

output "endpoint" {
  value = module.eks.cluster_endpoint
}

output "smtp_conf" {
  value = local.smtp_conf
}