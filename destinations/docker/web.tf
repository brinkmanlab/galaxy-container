resource "docker_image" "galaxy_web" {
  name = "${local.galaxy_web_image}:${var.image_tag}"
}

resource "docker_container" "galaxy_web" {
  name       = "${local.web_name}${local.name_suffix}"
  image      = docker_image.galaxy_web.latest
  hostname   = local.web_name
  domainname = local.web_name
  restart    = "unless-stopped"
  must_run   = true

  env = [ for k, v in local.master_api_key_conf : "${k}=${v}" ]

  ports {
    external = 80
    internal = 80
  }
  networks_advanced {
    name = local.network
  }
  mounts {
    source = docker_volume.user_data.name
    target = local.data_dir
    type   = "volume"
  }
}