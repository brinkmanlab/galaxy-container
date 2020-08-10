locals {
  db_conf = var.db_conf != null ? var.db_conf : {
    scheme = "postgres"
    host = var.db_name
    name = "galaxy${var.name_suffix}"
    user = "galaxy"
    pass = random_password.db_password[0].result
  }
}

variable "db_conf" {
  type = object({
    scheme = string
    host = string
    name = string
    user = string
    pass = string
  })
  default = null
  description = "Database configuration overrides"
}

resource "random_password" "db_password" {
  count = var.db_conf == null ? 1 : 0
  length = 16
  special = false
}

variable "depends" {
  default = null
}

variable "object_store_access_key" {
  type        = string
  default     = ""
  description = "Object store access key"
}

variable "object_store_secret_key" {
  type        = string
  default     = ""
  description = "Object store secret key"
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
  default = ""
  description = "Unique deployment instance identifier"
}

variable "name_suffix" {  # TODO eliminate this variable. Replace with docker network or k8s namespace
  type        = string
  default     = ""
  description = "Suffix to attach to all resource identifiers. This allows multiple instances to be ran without name collisions."
}

variable "galaxy_web_image" {
  type        = string
  default     = "brinkmanlab/galaxy_web"
  description = "Galaxy web server image name"
}

variable "galaxy_app_image" {
  type        = string
  default     = "brinkmanlab/galaxy_app"
  description = "Galaxy app server image name"
}

variable "db_image" {
  type        = string
  default     = "postgres:alpine"
  description = "MariaDB image name"
}

variable "galaxy_root_volume_name" {
  type        = string
  default     = "galaxy_root"
  description = "Galaxy root volume name"
}

variable "user_data_volume_name" {
  type        = string
  default     = "user_data"
  description = "User data volume name"
}

variable "db_data_volume_name" {
  type        = string
  default     = "db_data"
  description = "Database volume name"
}

variable "web_name" {
  type        = string
  default     = "galaxy_web"
  description = "Galaxy web server container name"
}

variable "app_name" {
  type        = string
  default     = "galaxy_app"
  description = "Galaxy application container name"
}

variable "worker_name" {
  type        = string
  default     = "galaxy_worker"
  description = "Galaxy worker container name"
}

variable "db_name" {
  type        = string
  default     = "galaxy_db"
  description = "Database container name"
}

variable "db_password" {
  type        = string
  default     = ""
  description = "Password for Galaxy database"
}