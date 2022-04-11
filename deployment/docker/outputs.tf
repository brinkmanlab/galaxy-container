output "galaxy_admin_username" {
  value = "admin"
  description = "Galaxy admin username"
}

output "galaxy_admin_password" {
  value     = module.admin_user.password
  sensitive = true
  description  = "Galaxy admin password"
}

output "galaxy_admin_api_key" {
  value     = module.admin_user.api_key
  sensitive = true
  description = "Galaxy admin api key"
}

output "galaxy_master_api_key" {
  value     = module.galaxy.master_api_key
  sensitive = true
  description = "Galaxy master api key"
}

output "galaxy_endpoint" {
  value = module.galaxy.endpoint
  description = "Galaxy front-end endpoint"
}