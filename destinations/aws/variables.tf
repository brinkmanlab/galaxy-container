locals {
  instance    = var.instance == "" ? "default" : var.instance
  name_suffix = var.instance == "" ? "" : "-${var.instance}"
  destination_galaxy_conf = {
    #TODO AWS SQS amqp_internal_connection: https://docs.celeryproject.org/projects/kombu/en/stable/userguide/connections.html#urls
    # https://docs.celeryproject.org/projects/kombu/en/latest/reference/kombu.transport.SQS.html#id1
  }
}

variable "eks" {
  description = "Instance of EKS module output state"
}

variable "vpc" {
  description = "Instance of VPC module output state"
}

variable "lb_annotations" {
  type        = map(string)
  default     = {}
  description = "Annotations to pass to the ingress load-balancer (https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer)"
}

variable "namespace" {
  default     = null
  description = "Instance of kubernetes_namespace to provision instance resources under"
}

variable "nfs_server" {
  type        = string
  default     = ""
  description = "URL to NFS server containing user data"
}

variable "extra_mounts" {
  type = map(object({
    claim_name = string
    path       = string
    read_only  = bool
  }))
  default     = {}
  description = "Map of mount configurations to add to app and worker containers keyed on volume name"
}

variable "web_max_replicas" {
  type        = number
  default     = 10
  description = "Maximum number of web replicas"
}

variable "app_max_replicas" {
  type        = number
  default     = 10
  description = "Maximum number of app replicas"
}

variable "worker_max_replicas" {
  type        = number
  default     = 10
  description = "Maximum number of worker replicas"
}