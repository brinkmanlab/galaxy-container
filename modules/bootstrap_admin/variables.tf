variable "galaxy_url" {
  type = string
  description = "Galaxy server url"
}

variable "username" {
  type = string
  description = "Username of admin user"
}

variable "email" {
  type = string
  description = "Email address (as specified in Galaxy admin_users config)"
}

variable "password" {
  type = string
  default = nil
  description = "Password of admin user"
}

variable "master_api_key" {
  type = string
  description = "Galaxy master API key"
}