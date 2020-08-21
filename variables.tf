variable "data_dir" {
  description = "Path to store user data"
  type        = string
  default     = "data/"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "email" {
  type        = string
  default     = ""
  description = "Email address to send automated emails from"
}

variable "db_conf" {
  type = object({
    scheme = string
    host   = string
    name   = string
    user   = string
    pass   = string
  })
  default     = null
  description = "Database configuration overrides"
}

variable "instance" {
  type        = string
  default     = ""
  description = "Specify a unique instance name for this deployment"
}