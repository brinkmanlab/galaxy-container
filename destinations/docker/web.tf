resource "docker_image" "galaxy_web" {
  name = "${local.galaxy_web_image}:${var.image_tag}"
  keep_locally = var.debug
}

resource "docker_container" "galaxy_web" {
  depends_on = [docker_container.wait_for_app]
  name       = "${local.web_name}${local.name_suffix}"
  image      = docker_image.galaxy_web.latest
  hostname   = local.web_name
  domainname = local.web_name
  restart    = "unless-stopped"
  must_run   = true

  env = ["master_api_key=${local.master_api_key}"]

  ports {
    external = var.host_port
    internal = 80
  }

  networks_advanced {
    name    = local.network
    aliases = [local.web_name]
  }

  healthcheck {
    test         = ["CMD", "wget", "--spider", "http://localhost/health"]
    start_period = "2s"
    timeout      = "2s"
    interval     = "10s"
    retries      = 3
  }

  mounts {
    source = docker_volume.user_data.name
    target = local.data_dir
    type   = "volume"
  }
}