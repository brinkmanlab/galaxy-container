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
  default = ""
  description = "Password of admin user"
  #sensitive = true
}

variable "master_api_key" {
  type = string
  description = "Galaxy master API key"
  #sensitive = true
}