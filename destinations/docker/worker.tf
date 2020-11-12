locals {
  job_conf = merge({
    DOCKER_ENABLED   = "True"
    CWD = local.root_dir,
    DEFAULT_CONTAINER_ID = docker_image.galaxy_worker.latest,
  }, local.name_suffix == "" ? {} : {
    DOCKER_VOLUME_MOUNTS = "${local.galaxy_root_volume_name}${local.name_suffix}:$galaxy_root:ro,${local.user_data_volume_name}${local.name_suffix}:/data:rw,$working_directory:rw"
  })
}

resource "docker_image" "galaxy_worker" {
  name = "${local.galaxy_app_image}:${var.image_tag}"
}

resource "docker_container" "galaxy_worker" {
  depends_on = [docker_container.upgrade_db]
  name  = "${local.worker_name}${local.name_suffix}"
  image = docker_image.galaxy_worker.latest
  # https://docs.galaxyproject.org/en/master/admin/scaling.html#uwsgi-for-web-serving-and-webless-galaxy-applications-as-job-handlers
  command = ["sh", "-c", "/env_run.sh python3 ${local.root_dir}/scripts/galaxy-main -c ${local.config_dir}/galaxy.yml --server-name=$HOSTNAME --log-file=/dev/stdout --attach-to-pool=job-handlers"]
  hostname   = local.worker_name
  domainname = local.worker_name
  restart    = "unless-stopped"
  must_run   = true
  user       = "${local.uwsgi_user}:${local.uwsgi_group}"
  group_add  = ["969"]

  networks_advanced {
    name = local.network
  }

  env = compact(concat(
    [for k, v in local.galaxy_conf: "GALAXY_CONFIG_OVERRIDE_${k}=${v}"],
    [for k, v in local.job_conf: "${k}=${v}"],
  ))

  healthcheck {
    test = ["sh", "-c", "/env_run.sh python ${local.root_dir}/probedb.py -v -c \"$GALAXY_CONFIG_OVERRIDE_database_connection\" -s $HOSTNAME"]
    start_period = "2s"
    timeout = "30s"
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
    target = "/var/run/docker.sock"
    source = "/var/run/docker.sock"
    type   = "bind"
  }
  mounts {
    source = docker_volume.user_data.name
    target = local.data_dir
    type   = "volume"
  }
  mounts {
    source = docker_volume.galaxy_root.name
    target = local.root_dir
    type   = "volume"
  }
}