locals {
  password = var.password != "" ? var.password : random_password.admin_user.0.result
}

resource "random_password" "admin_user" {
  count = var.password == "" ? 1 : 0
  length  = 16
  special = false
}

# Configure a aliased Galaxy provider with the master API key
provider "galaxy" {
  host = var.galaxy_url
  api_key = var.master_api_key
  alias = "master"
}

# Use the master API key to create the admin user
resource "galaxy_user" "admin" {
  provider = galaxy.master
  username = var.username
  password = local.password
  email = var.email
}