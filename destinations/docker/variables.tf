locals {
  name_suffix = var.instance == "" ? "" : "-${var.instance}"
  destination_galaxy_conf = {
    #retry_metadata_internally = true
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