output "nfs_server" {
  value = aws_efs_file_system.user_data.dns_name
}