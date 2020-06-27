locals {
  ansible = yamldecode(file("${path.root}/vars.yml"))
}

variable "object_store_access_key" {
  type = string
  default = random_string.object_store_access_key
}

variable "object_store_secret_key" {
  type = string
  default = random_password.object_store_secret_key
}

variable "data_dir" {
  description = "Path to store user data"
  type = string
  default = "data/"
}

variable "region" {
  type = string
  default = local.region
}