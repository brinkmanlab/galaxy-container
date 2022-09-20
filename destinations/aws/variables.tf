locals {
  instance                = var.instance == "" ? "default" : var.instance
  name_suffix             = var.instance == "" ? "" : "-${var.instance}"
  destination_galaxy_conf = {
    # AWS SQS amqp_internal_connection: https://docs.celeryproject.org/projects/kombu/en/stable/userguide/connections.html#urls
    # https://docs.celeryproject.org/projects/kombu/en/latest/reference/kombu.transport.SQS.html#id1
    # https://docs.celeryq.dev/en/stable/getting-started/backends-and-brokers/sqs.html
    amqp_internal_connection = "sqs://"
  }
  extra_env = merge({
    AWS_DEFAULT_REGION           = data.aws_region.current.name
    CELERY_ENABLE_REMOTE_CONTROL = "False"
    #BROKER_TRANSPORT_OPTIONS     = jsonencode({ # TODO cant pass this option as env var
    #  predefined_queues : {
    #    celery : { url : aws_sqs_queue.celery.url },
    #    galaxy-internal : { url : aws_sqs_queue.galaxy-internal.url },
    #    galaxy-external : { url : aws_sqs_queue.galaxy-external.url },
    #  }
    #})
  }, var.extra_env)
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

variable "celery_worker_max_replicas" {
  type        = number
  default     = 10
  description = "Maximum number of celery worker replicas"
}

variable "tusd_max_replicas" {
  type        = number
  default     = 10
  description = "Maximum number of TUSd replicas"
}