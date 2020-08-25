locals {
  instance     = var.instance == "" ? "default" : var.instance
  name_suffix  = var.instance == "" ? "" : "-${var.instance}"
}

variable "eks" {
  description = "Instance of EKS module output state"
}

variable "vpc" {
  description = "Instance of VPC module output state"
}

