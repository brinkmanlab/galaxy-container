locals {
  ansible                 = yamldecode(file("${path.root}/vars.yml"))
  object_store_access_key = var.object_store_access_key != "" ? var.object_store_access_key : random_string.object_store_access_key.result
  object_store_secret_key = var.object_store_secret_key != "" ? var.object_store_secret_key : random_password.object_store_secret_key.result
  db_password             = var.db_password != "" ? var.db_password : regex("(?m)^galaxy_db.*db_secret=(?P<db_secret>[^ ]+)", file("inventory.ini")).db_secret
  name_suffix             = local.ansible.instance != "" ? "-${local.ansible.instance}" : ""
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
  name_suffix             = local.name_suffix
  web_name                = local.ansible.containers.web.name
  app_name                = local.ansible.containers.app.name
  worker_name             = local.ansible.containers.worker.name
  db_name                 = local.ansible.containers.db.name
  db_password             = local.db_password
  db_data_volume_name     = local.ansible.volumes.db_data.name
  galaxy_root_volume_name = local.ansible.volumes.galaxy_root.name
  user_data_volume_name   = local.ansible.volumes.user_data.name
  data_dir                = local.ansible.paths.data
  root_dir                = local.ansible.paths.root
  config_dir              = local.ansible.paths.config
  region                  = var.region
  #object_store_access_key = ""
  #object_store_secret_key = ""
  image_tag = var.image_tag
  #db_image = ""
  #galaxy_app_image = ""
  #galaxy_web_image = ""
}