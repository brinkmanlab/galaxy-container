locals {
  name_suffix = var.instance == "" ? "" : "-${var.instance}"
  instance    = var.instance == "" ? "default" : var.instance
  destination_galaxy_conf = {
  }
}

variable "nfs_server" {
  type        = string
  description = "URL to NFS server containing user data"
}