locals {
  ansible        = yamldecode(file("${path.module}/vars.yml"))

  data_dir = var.data_dir != null ? var.data_dir : local.ansible.paths.data
  root_dir = var.root_dir != null ? var.root_dir : local.ansible.paths.root
  config_dir = var.config_dir != null ? var.config_dir : local.ansible.paths.config
  galaxy_web_image = var.galaxy_web_image != null ? var.galaxy_web_image : "brinkmanlab/${local.ansible.containers.web.name}"
  galaxy_app_image = var.galaxy_app_image != null ? var.galaxy_app_image : "brinkmanlab/${local.ansible.containers.app.name}"
  db_image = var.db_image != null ? var.db_image : "postgres:alpine"
  galaxy_root_volume_name = var.galaxy_root_volume_name != null ? var.galaxy_root_volume_name : local.ansible.volumes.galaxy_root.name
  user_data_volume_name = var.user_data_volume_name != null ? var.user_data_volume_name : local.ansible.volumes.user_data.name
  db_data_volume_name = var.db_data_volume_name != null ? var.db_data_volume_name : local.ansible.volumes.db_data.name
  web_name = var.web_name != null ? var.web_name : local.ansible.containers.web.name
  app_name = var.app_name != null ? var.app_name : local.ansible.containers.app.name
  worker_name = var.worker_name != null ? var.worker_name : local.ansible.containers.worker.name
  db_name = var.db_name != null ? var.db_name : local.ansible.containers.db.name
  uwsgi_port = var.uwsgi_port != null ? var.uwsgi_port : local.ansible.uwsgi.port

  mail_name   = var.mail_name != null ? var.mail_name : regex("(?m)^mail.*hostname=(?P<mail_name>[^ ]+)", file("${path.root}/galaxy/inventory.ini")).mail_name
  mail_port   = var.mail_port != null ? var.mail_port : regex("(?m)^mail.*port=(?P<mail_port>[^ ]+)", file("${path.root}/inventory.ini")).mail_port

  db_conf = var.db_conf != null ? var.db_conf : {
    scheme = "postgres"
    host   = var.db_name
    name   = "galaxy${local.name_suffix}"
    user   = "galaxy"
    pass   = random_password.db_password[0].result
  }
  master_api_key = var.master_api_key != "" ? var.master_api_key : random_password.master_api_key[0].result
  master_api_key_conf = {
    master_api_key = local.master_api_key
  }
  admin_users_conf = length(var.admin_users) == 0 ? {} : {
    admin_users = join(",", var.admin_users)
  }
  galaxy_conf = merge(var.galaxy_conf, local.master_api_key_conf, local.admin_users_conf)
}

variable "db_conf" {
  type = object({
    scheme = string
    host   = string
    name   = string
    user   = string
    pass   = string
  })
  default     = null
  description = "Database configuration overrides"
}

resource "random_password" "db_password" {
  count   = var.db_conf == null ? 1 : 0
  length  = 16
  special = false
}

variable "master_api_key" {
  type        = string
  default     = ""
  description = "Galaxy master API key"
}

resource "random_password" "master_api_key" {
  count   = var.master_api_key != "" ? 0 : 1
  length  = 32
  special = false
}

variable "galaxy_conf" {
  type        = map(string)
  default     = {}
  description = "Galaxy configuration overrides"
}

variable "image_tag" {
  type        = string
  default     = "latest"
  description = "Tag for galaxy_web and galaxy_app image"
}

variable "instance" {
  type        = string
  default     = ""
  description = "Unique deployment instance identifier"
}

variable "data_dir" {
  type        = string
  default     = null
  description = "Path to user data within container"
}

variable "root_dir" {
  type        = string
  default     = null
  description = "Path to galaxy root folder within container"
}

variable "config_dir" {
  type        = string
  default     = null
  description = "Path to galaxy configuration folder within container"
}

variable "galaxy_web_image" {
  type        = string
  default     = null
  description = "Galaxy web server image name"
}

variable "galaxy_app_image" {
  type        = string
  default     = null
  description = "Galaxy app server image name"
}

variable "db_image" {
  type        = string
  default     = null
  description = "MariaDB image name"
}

variable "galaxy_root_volume_name" {
  type        = string
  default     = null
  description = "Galaxy root volume name"
}

variable "user_data_volume_name" {
  type        = string
  default     = null
  description = "User data volume name"
}

variable "db_data_volume_name" {
  type        = string
  default     = null
  description = "Database volume name"
}

variable "web_name" {
  type        = string
  default     = null
  description = "Galaxy web server container name"
}

variable "app_name" {
  type        = string
  default     = null
  description = "Galaxy application container name"
}

variable "worker_name" {
  type        = string
  default     = null
  description = "Galaxy worker container name"
}

variable "db_name" {
  type        = string
  default     = null
  description = "Database container name"
}

variable "uwsgi_port" {
  type        = number
  default     = null
  description = "Port Galaxy UWSGI server is listening from"
}

variable "mail_name" {
  type        = string
  default     = "mail"
  description = "SMTP server name"
}

variable "mail_port" { # TODO is it actually required to specify the port?
  type        = number
  default     = 587
  description = "Port to connect to SMTP server"
}

variable "admin_users" {
  type        = set(string)
  default     = ["admin@brinkmanlab.ca"]
  description = "List of email addresses for Galaxy admin users"
}

variable "email" {
  type        = string
  description = "Email address to send automated emails from"
}

variable "debug" {
  type        = bool
  default     = false
  description = "Enabling will put the deployment into a mode suitable for debugging"
}