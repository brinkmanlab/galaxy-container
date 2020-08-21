locals {
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

variable "data_dir" {
  type        = string
  default     = "data/"
  description = "Path to user data within container"
}

variable "root_dir" {
  type        = string
  default     = "/srv/galaxy"
  description = "Path to galaxy root folder within container"
}

variable "config_dir" {
  type        = string
  default     = "/srv/galaxy/config"
  description = "Path to galaxy configuration folder within container"
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

variable "galaxy_web_image" {
  type        = string
  default     = "brinkmanlab/galaxy-web"
  description = "Galaxy web server image name"
}

variable "galaxy_app_image" {
  type        = string
  default     = "brinkmanlab/galaxy-app"
  description = "Galaxy app server image name"
}

variable "db_image" {
  type        = string
  default     = "postgres:alpine"
  description = "MariaDB image name"
}

variable "galaxy_root_volume_name" {
  type        = string
  default     = "galaxy-root"
  description = "Galaxy root volume name"
}

variable "user_data_volume_name" {
  type        = string
  default     = "user-data"
  description = "User data volume name"
}

variable "db_data_volume_name" {
  type        = string
  default     = "db-data"
  description = "Database volume name"
}

variable "web_name" {
  type        = string
  default     = "galaxy-web"
  description = "Galaxy web server container name"
}

variable "app_name" {
  type        = string
  default     = "galaxy-app"
  description = "Galaxy application container name"
}

variable "worker_name" {
  type        = string
  default     = "galaxy-worker"
  description = "Galaxy worker container name"
}

variable "db_name" {
  type        = string
  default     = "galaxy-db"
  description = "Database container name"
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

variable "uwsgi_port" {
  type        = number
  default     = 9000
  description = "Port Galaxy UWSGI server is listening from"
}