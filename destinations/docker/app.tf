resource "docker_image" "galaxy_app" {
  name = "${local.galaxy_app_image}:${var.image_tag}"
}

resource "docker_container" "galaxy_app" {
  depends_on = [docker_container.upgrade_db, docker_container.visualizations]
  name       = "${local.app_name}${local.name_suffix}"
  image      = docker_image.galaxy_app.latest
  hostname   = local.app_name
  domainname = local.app_name
  restart    = "unless-stopped"
  must_run   = true
  user       = "${local.uwsgi_user}:${local.uwsgi_group}"

  networks_advanced {
    name = local.network
    aliases = [local.app_name]
  }

  env = compact(concat(
    [for k, v in local.galaxy_conf: "GALAXY_CONFIG_OVERRIDE_${k}=${v}"],
    [for k, v in local.job_conf: "${k}=${v}"],
  ))

  healthcheck {
    test = ["CMD", "uwping", "uwsgi://localhost:${local.uwsgi_port}/api/version"]
    start_period = "2s"
    timeout = "2s"
    interval = "10s"
    retries = 3
  }

  dynamic "upload" {
    for_each = local.configs
    content {
      file = "${local.config_dir}/macros/${upload.key}"
      content = upload.value
    }
  }

  mounts {
    source = docker_volume.user_data.name
    target = local.data_dir
    type   = "volume"
    read_only = false
  }

  mounts {
    source = docker_volume.galaxy_root.name
    target = local.root_dir
    type = "volume"
    read_only = false
  }

  dynamic "mounts" {
    for_each = var.extra_mounts
    content {
      source = mounts.value.source
      target = mounts.value.target
      type = mounts.value.type
      read_only = mounts.value.read_only
    }
  }
}

resource "docker_container" "wait_for_app" {
  depends_on = [docker_container.galaxy_app]
  image = docker_image.galaxy_app.latest
  name = "wait_for_galaxy_app${local.name_suffix}"
  must_run = false
  attach = true
  command = ["bash", "-c", "until uwping uwsgi://${local.app_name}:${local.uwsgi_port}/api/version; do sleep 1; done"]
  networks_advanced {
    name = local.network
  }
}