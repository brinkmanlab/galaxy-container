locals {
  ansible = yamldecode(file("${path.root}/vars.yml"))
  mail_name   = regex("(?m)^mail.*hostname=(?P<mail_name>[^ ]+)", file("${path.root}/inventory.ini")).mail_name
  mail_port   = regex("(?m)^mail.*port=(?P<mail_port>[^ ]+)", file("${path.root}/inventory.ini")).mail_port
  name_suffix = var.instance != "" ? "-${var.instance}" : ""
  region = "us-west-2"
}

## Docker Config

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

## AWS Config

provider "aws" {
  region  = local.region
  version = "~> 2.0"
}

module "destination" {
  source                  = "./destinations/docker"
  instance                = var.instance
  galaxy_conf = {
    email_from     = var.email
    error_email_to = var.email
  }
  image_tag = var.image_tag
  mail_name = local.mail_name
  mail_port = local.mail_port
}