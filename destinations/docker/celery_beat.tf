resource "docker_container" "galaxy_celery_beat" {
  depends_on = [docker_container.upgrade_db]
  name       = "${local.celery_beat_name}${local.name_suffix}"
  image      = docker_image.galaxy_app.latest
  # https://github.com/galaxyproject/galaxy-helm/blob/4eb8aa0f5158f8a5e16869869a7e47bcad700206/galaxy/templates/deployment-celery.yaml#L68
  command    = [
    "celery",
    "--app", "galaxy.celery", "beat",
    "--loglevel", "DEBUG",
    "--schedule", "${local.data_dir}/database/celery-beat-schedule"
  ]
  hostname   = "${local.celery_beat_name}"
  domainname = "${local.celery_beat_name}"
  restart    = "unless-stopped"
  must_run   = true
  user       = "${local.app_user}:${local.app_group}"

  networks_advanced {
    name = local.network
  }

  env = compact(concat(
    [for k, v in local.galaxy_conf : "GALAXY_CONFIG_OVERRIDE_${k}=${v}"],
    [for k, v in local.job_conf : "${k}=${v}"],
  ))

  healthcheck {
    test = [
      "bash",
      "-c",
      "celery -A galaxy.celery inspect ping -d celery@$HOSTNAME"
    ]
    start_period = "2s"
    timeout      = "30s"
    interval     = "10s"
    retries      = 3
  }

  dynamic "upload" {
    for_each = local.configs
    content {
      file    = "${local.config_dir}/${upload.key}"
      content = upload.value
    }
  }

  dynamic "upload" {
    for_each = local.macros
    content {
      file    = "${local.config_dir}/macros/${upload.key}"
      content = upload.value
    }
  }

  mounts {
    source = docker_volume.user_data.name
    target = local.data_dir
    type   = "volume"
  }

  dynamic "mounts" {
    for_each = var.extra_mounts
    content {
      source    = mounts.value.source
      target    = mounts.value.target
      type      = mounts.value.type
      read_only = mounts.value.read_only
    }
  }
}