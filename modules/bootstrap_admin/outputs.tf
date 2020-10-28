output "password" {
  value = var.password != nil ? var.password : random_password.admin_user.0.result
  sensitive = true
}

output "api_key" {
  value = galaxy_user.admin.api_key
  sensitive = true
}