locals {
  name_suffix = var.instance == "" ? "" : "-${var.instance}"
}

variable "network" {
  type        = string
  default     = ""
  description = "Docker network name"
}