module "galaxy" {
  source   = "../../destinations/docker"
  instance = var.instance
  galaxy_conf = {
    email_from     = var.email
    error_email_to = var.email
    require_login  = true
  }
  image_tag   = "dev"
  admin_users = [var.email]
  email       = var.email
  debug       = var.debug
  host_port = var.host_port
  docker_gid = var.docker_gid
}

module "admin_user" {
  source         = "../../modules/bootstrap_admin"
  email          = var.email
  galaxy_url     = "http://localhost:${module.galaxy.host_port}"
  master_api_key = module.galaxy.master_api_key
  username       = "admin"
}

provider "galaxy" {
  host    = "http://${module.galaxy.endpoint}"
  api_key = module.admin_user.api_key
}