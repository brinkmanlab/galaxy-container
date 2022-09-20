resource "docker_container" "galaxy_celery_worker" {
  depends_on = [docker_container.upgrade_db]
  count      = var.celery_worker_max_replicas
  name       = "${local.celery_worker_name}-${count.index}${local.name_suffix}"
  image      = docker_image.galaxy_app.latest
  # https://github.com/galaxyproject/galaxy-helm/blob/4eb8aa0f5158f8a5e16869869a7e47bcad700206/galaxy/templates/deployment-celery.yaml#L68
  command    = [
    "celery",
    "--app", "galaxy.celery", "worker",
    "--concurrency", "2",
    "--loglevel", "DEBUG",
    "--pool", "threads",
    "--queues", "celery,galaxy.internal,galaxy.external"
  ]
  hostname   = "${local.celery_worker_name}-${count.index}"
  domainname = "${local.celery_worker_name}-${count.index}"
  restart    = "unless-stopped"
  must_run   = true
  user       = "${local.app_user}:${local.app_group}"

  networks_advanced {
    name = local.network
  }

  env = compact(concat(
    [for k, v in local.galaxy_conf : "GALAXY_CONFIG_OVERRIDE_${k}=${v}"],
    [for k, v in local.job_conf : "${k}=${v}"],
    [for k, v in var.extra_env : "${k}=${v}"],
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