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