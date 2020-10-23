locals {
  name_suffix = var.instance == "" ? "" : "-${var.instance}"
  instance    = var.instance == "" ? "default" : var.instance
  destination_galaxy_conf = {
    retry_metadata_internally = true  # k8s depends on the metadata fallback
  }
}

variable "nfs_server" {
  type        = string
  description = "URL to NFS server containing user data"
}