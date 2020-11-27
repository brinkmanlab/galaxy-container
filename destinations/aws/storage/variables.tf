locals {
  name_suffix  = var.instance == "" ? "" : "-${var.instance}"
}

variable "user_data_volume_name" {
  type        = string
  description = "User data volume name"
}

variable "instance" {
  type        = string
  description = "Unique deployment instance identifier"
}

variable "vpc" {}