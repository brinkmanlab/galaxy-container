locals {
  job_conf = {
    K8S_ENABLED   = "True"
    K8S_NAMESPACE = local.instance
    K8S_VOLUMES   = "${kubernetes_persistent_volume_claim.user_data.metadata.0.name}:${local.data_dir}"
    K8S_DEFAULT_IMAGE_TAG = var.image_tag
  }
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
}