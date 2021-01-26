locals {
  name_suffix = var.instance == "" ? "" : "-${var.instance}"
  instance    = var.instance == "" ? "default" : var.instance
  namespace = var.namespace == null ? nomad_namespace.galaxy[0] : var.namespace
  destination_galaxy_conf = {
    retry_metadata_internally = true  # depends on the metadata fallback
  }
}

variable "namespace" {
  default = null
  description = "Instance of nomad_namespace to provision instance resources under"
}

variable "nfs_server" {
  type        = string
  default = ""
  description = "External ID to NFS server volume containing user data"
}

variable "extra_mounts" {
  type = map(object({
    volume_id = string
    path = string
    read_only = bool
  }))
  default = {}
  description = "Map of mount configurations to add to app and worker containers keyed on volume name"
}
