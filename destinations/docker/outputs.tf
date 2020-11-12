output "db_root" {
  value       = random_password.db_root.result
  sensitive   = true
  description = "Password for root user in DB container"
}

output "endpoint" {
  value = "galaxy"
}