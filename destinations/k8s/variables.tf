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

variable "lb_annotations" {
  type = map(string)
  default = {}
  description = "Annotations to pass to the ingress load-balancer (https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer)"
}

variable "namespace" {
  default = null
  description = "Instance of kubernetes_namespace to provision instance resources under"
}

variable "extra_mounts" {
  type = map(object({
    claim_name = string
    path = string
    read_only = bool
  }))
  default = {}
  description = "Map of mount configurations to add to app and worker containers keyed on volume name"
}