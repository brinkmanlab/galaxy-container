resource "docker_image" "galaxy_web" {
  name = "${local.galaxy_web_image}:${var.image_tag}"
}

resource "docker_container" "galaxy_web" {
  name       = "${local.web_name}${local.name_suffix}"
  image      = docker_image.galaxy_web.latest
  hostname   = "galaxy_web"
  domainname = "galaxy_web"
  restart    = "unless-stopped"
  must_run   = true
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