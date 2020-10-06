resource "docker_image" "galaxy_app" {
  name = "${local.galaxy_app_image}:${var.image_tag}"
}

resource "docker_container" "galaxy_app" {
  depends_on = [docker_container.upgrade_db]
  name       = "${local.app_name}${local.name_suffix}"
  image      = docker_image.galaxy_app.latest
  hostname   = local.app_name
  domainname = local.app_name
  restart    = "unless-stopped"
  must_run   = true
  user       = "${local.uwsgi_user}:${local.uwsgi_group}"

  env = concat(
    [ for k, v in local.galaxy_conf : "GALAXY_CONFIG_OVERRIDE_${k}=${v}"],
    [ for k, v in local.job_conf : "${k}=${v}"]
  )

  networks_advanced {
    name = local.network
  }
  mounts {
    source = docker_volume.user_data.name
    target = local.data_dir
    type   = "volume"
  }
}

