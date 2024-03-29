locals {
  job_conf = merge({
    DOCKER_ENABLED       = "True"
    CWD                  = local.root_dir,
    DEFAULT_CONTAINER_ID = docker_image.galaxy_app.latest,
    }, local.name_suffix == "" ? {} : {
    DOCKER_VOLUME_MOUNTS = "${local.galaxy_root_volume_name}${local.name_suffix}:$galaxy_root:ro,${local.user_data_volume_name}${local.name_suffix}:/data:rw${length(var.extra_job_mounts) > 0 ? "," : ""}${join(",", var.extra_job_mounts)}"
  })
}

resource "docker_container" "galaxy_worker" {
  depends_on = [docker_container.upgrade_db]
  count = var.worker_max_replicas
  name       = "${local.worker_name}-${count.index}${local.name_suffix}"
  image      = docker_image.galaxy_app.latest
  # https://docs.galaxyproject.org/en/master/admin/scaling.html#app-for-web-serving-and-webless-galaxy-applications-as-job-handlers
  command    = ["sh", "-c", "python3 ${local.root_dir}/scripts/galaxy-main -c ${local.config_dir}/galaxy.yml --server-name=$HOSTNAME --log-file=/dev/stdout --attach-to-pool=job-handlers --attach-to-pool=workflow-schedulers"]
  hostname   = "${local.worker_name}-${count.index}"
  domainname = "${local.worker_name}-${count.index}"
  restart    = "unless-stopped"
  must_run   = true
  user       = "${local.app_user}:${local.app_group}"
  group_add  = [var.docker_gid]

  networks_advanced {
    name = local.network
  }

  env = compact(concat(
    [for k, v in local.galaxy_conf : "GALAXY_CONFIG_OVERRIDE_${k}=${v}"],
    [for k, v in local.job_conf : "${k}=${v}"],
    ["DOCKER_HOST=unix://${var.docker_socket_path}"],
    [for k, v in var.extra_env : "${k}=${v}"],
  ))

  /* TODO https://github.com/galaxyproject/galaxy/issues/10894
  healthcheck {
    test = ["sh", "-c", "python ${local.root_dir}/probedb.py -v -c \"$GALAXY_CONFIG_OVERRIDE_database_connection\" -s $HOSTNAME"]
    start_period = "2s"
    timeout = "30s"
    interval = "10s"
    retries = 3
  }*/

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
    target = var.docker_socket_path
    source = var.docker_socket_path
    type   = "bind"
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