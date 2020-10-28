resource "docker_image" "galaxy_worker" {
  name = "${local.galaxy_app_image}:${var.image_tag}"
}

resource "docker_container" "galaxy_worker" {
  name  = "${local.worker_name}${local.name_suffix}"
  image = docker_image.galaxy_worker.latest
  # https://docs.galaxyproject.org/en/master/admin/scaling.html#uwsgi-for-web-serving-and-webless-galaxy-applications-as-job-handlers
  command = ["/env_run.sh", "python3", "${local.root_dir}/scripts/galaxy-main", "-c", "${local.config_dir}/galaxy.yml", "--server-name=${local.worker_name}${local.name_suffix}", "--log-file=/dev/stdout", "--attach-to-pool=job-handlers"]
  # /env_run.sh "python3" "/srv/galaxy/scripts/galaxy-main" "-c" "/srv/galaxy/config/galaxy.yml" "--server-name=$HOSTNAME" "--log-file=/dev/stdout" --attach-to-pool=job-handlers
  hostname   = "galaxy_worker"
  domainname = "galaxy_worker"
  restart    = "unless-stopped"
  must_run   = true
  user       = "galaxy:galaxy"
  group_add  = ["969"]
  env = compact([
    local.name_suffix == "" ? "" : "DOCKER_VOLUME_MOUNTS='${local.galaxy_root_volume_name}${local.name_suffix}:$galaxy_root:ro,${local.user_data_volume_name}${local.name_suffix}:/data:rw,$working_directory:rw'",
    "CWD=${local.root_dir}",
    "DEFAULT_CONTAINER_ID=${docker_image.galaxy_worker.latest}",
    "DOCKER_ENABLED=True"
  ])
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
    source = docker_volume.galaxy_root.name #"${local.ansible.volumes.galaxy_root.name}${local.name_suffix}"
    target = local.root_dir
    type   = "volume"
  }
  networks_advanced {
    name = local.network
  }
  depends_on = [docker_container.galaxy_db]
}