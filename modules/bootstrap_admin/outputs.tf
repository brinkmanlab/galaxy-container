output "password" {
  value = local.password
  sensitive = true
}

output "api_key" {
  value = galaxy_user.admin.api_key
  sensitive = true
}