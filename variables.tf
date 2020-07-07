locals {
  ansible                 = yamldecode(file("${path.root}/vars.yml"))
  object_store_access_key = var.object_store_access_key != "" ? var.object_store_access_key : random_string.object_store_access_key.result
  object_store_secret_key = var.object_store_secret_key != "" ? var.object_store_secret_key : random_password.object_store_secret_key.result
  db_password             = var.db_password != "" ? var.db_password : regex("(?m)^galaxy_db.*db_secret=(?P<db_secret>[^ ]+)", file("inventory.ini")).db_secret
  name_suffix             = local.ansible.instance != "" ? "-${local.ansible.instance}" : ""
}

variable "object_store_access_key" {
  type    = string
  default = ""
}

variable "object_store_secret_key" {
  type    = string
  default = ""
}

variable "data_dir" {
  description = "Path to store user data"
  type        = string
  default     = "data/"
}

variable "region" {
  type    = string
  default = ""
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "db_password" {
  type = string
  default = ""
}