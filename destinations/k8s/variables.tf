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
  default = {"service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout": 120}
  description = "Annotations to pass to the ingress load-balancer (https://gist.github.com/mgoodness/1a2926f3b02d8e8149c224d25cc57dc1)"
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