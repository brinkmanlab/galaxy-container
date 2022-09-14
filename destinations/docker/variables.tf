locals {
  mq_name                = var.mq_name != null ? var.mq_name : local.ansible.containers.mq.name
  mq_image                = var.mq_image != null ? var.mq_image : local.ansible.containers.mq.image
  mq_data_volume_name     = var.mq_data_volume_name != null ? var.mq_data_volume_name : local.ansible.volumes.mq_data.name

  name_suffix = var.instance == "" ? "" : "-${var.instance}"
  destination_galaxy_conf = {
    #retry_metadata_internally = true
    amqp_internal_connection = "amqp://guest:guest@${local.mq_name}:5672//"
  }
}

variable "network" {
  type        = string
  default     = ""
  description = "Docker network name"
}

variable "host_port" {
  type        = number
  default     = null
  description = "Host port to expose galaxy service"
}

variable "extra_mounts" {
  type = set(object({
    source    = string
    target    = string
    type      = string
    read_only = bool
  }))
  default     = []
  description = "Set of mount configurations to add to app and worker containers"
}

variable "docker_gid" {
  type        = number
  description = "GID with write permission to /var/run/docker.sock"
}

variable "docker_socket_path" {
  type        = string
  description = "Host path to docker socket"
  default     = "/var/run/docker.sock"
}

variable "worker_max_replicas" {
  type        = number
  default     = 1
  description = "Number of worker replicas"
}

variable "celery_worker_max_replicas" {
  type        = number
  default     = 1
  description = "Number of celery worker replicas"
}

variable "mq_name" {
  type        = string
  default     = null
  description = "Message queue container name"
}

variable "mq_image" {
  type        = string
  default     = null
  description = "Message queue image name"
}

variable "mq_data_volume_name" {
  type        = string
  default     = null
  description = "Message queue volume name"
}