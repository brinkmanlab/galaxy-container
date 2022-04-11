output "galaxy_admin_password" {
  value = module.admin_user.password
  description = "Galaxy Administrator Password"
}

output "galaxy_endpoint" {
  value = module.galaxy.endpoint
  description = "Galaxy front-end endpoint"
}