locals {
  ansible = yamldecode(file("${path.root}/vars.yml"))
  #object_store_access_key = var.object_store_access_key != "" ? var.object_store_access_key : random_string.object_store_access_key.result
  #object_store_secret_key = var.object_store_secret_key != "" ? var.object_store_secret_key : random_password.object_store_secret_key.result
  mail_name   = regex("(?m)^mail.*hostname=(?P<mail_name>[^ ]+)", file("${path.root}/inventory.ini")).mail_name
  mail_port   = regex("(?m)^mail.*port=(?P<mail_port>[^ ]+)", file("${path.root}/inventory.ini")).mail_port
  name_suffix = var.instance != "" ? "-${var.instance}" : ""
}

## Docker Config

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

## AWS Config

provider "aws" {
  region  = var.region
  version = "~> 2.0"
}

module "destination" {
  source                  = "./destinations/docker"
  web_name                = local.ansible.containers.web.name
  app_name                = local.ansible.containers.app.name
  worker_name             = local.ansible.containers.worker.name
  db_name                 = local.ansible.containers.db.name
  db_data_volume_name     = local.ansible.volumes.db_data.name
  galaxy_root_volume_name = local.ansible.volumes.galaxy_root.name
  user_data_volume_name   = local.ansible.volumes.user_data.name
  data_dir                = local.ansible.paths.data
  root_dir                = local.ansible.paths.root
  config_dir              = local.ansible.paths.config
  galaxy_app_image        = "brinkmanlab/${local.ansible.containers.app.name}"
  galaxy_web_image        = "brinkmanlab/${local.ansible.containers.web.name}"
  instance                = var.instance
  galaxy_conf = {
    email_from     = var.email
    error_email_to = var.email
  }
  image_tag = var.image_tag
  mail_name = local.mail_name
  mail_port = local.mail_port
}