locals {
  ansible = yamldecode(file("${path.root}/vars.yml"))
  object_store_access_key = var.object_store_access_key != "" ? var.object_store_access_key : random_string.object_store_access_key
  object_store_secret_key = var.object_store_secret_key != "" ? var.object_store_secret_key : random_password.object_store_secret_key
}

variable "object_store_access_key" {
  type = string
  default = ""
}

variable "object_store_secret_key" {
  type = string
  default = ""
}

variable "data_dir" {
  description = "Path to store user data"
  type = string
  default = "data/"
}

variable "region" {
  type = string
  default = ""
}