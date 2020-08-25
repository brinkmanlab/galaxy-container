locals {
  network = length(docker_network.galaxy_network) == 1 ? docker_network.galaxy_network[0].name : var.network
}

resource "docker_image" "galaxy_app" {
  name = "${local.galaxy_app_image}:${var.image_tag}"
}

resource "docker_image" "galaxy_web" {
  name = "${local.galaxy_web_image}:${var.image_tag}"
}

resource "docker_image" "galaxy_worker" {
  name = "${local.galaxy_app_image}:${var.image_tag}"
}

resource "docker_image" "galaxy_db" {
  name = local.db_image
}

resource "docker_volume" "galaxy_root" {
  name = "${local.galaxy_root_volume_name}${local.name_suffix}"
}

resource "docker_volume" "user_data" {
  name = "${local.user_data_volume_name}${local.name_suffix}"
}

resource "docker_volume" "db_data" {
  name = "${local.db_data_volume_name}${local.name_suffix}"
}

resource "docker_network" "galaxy_network" {
  count = var.network != "" ? 0 : 1
  name  = "galaxy_network${local.name_suffix}"
}

resource "docker_container" "galaxy_app" {
  name       = "${local.app_name}${var.name_suffix}"
  image      = docker_image.galaxy_app.latest
  hostname   = "galaxy_app"
  domainname = "galaxy_app"
  restart    = "unless-stopped"
  must_run   = true
  user       = "galaxy:galaxy"
  networks_advanced {
    name = local.network
  }
  mounts {
    source = docker_volume.user_data.name
    target = local.data_dir
    type   = "volume"
  }
  depends_on = [docker_container.galaxy_db]
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

resource "docker_container" "galaxy_db" {
  name       = "${local.db_name}${local.name_suffix}"
  image      = docker_image.galaxy_db.latest
  hostname   = "galaxy_db"
  domainname = "galaxy_db"
  restart    = "unless-stopped"
  must_run   = true
  env = [
    "POSTGRES_PASSWORD=${var.db_conf.pass}",
    "POSTGRES_USER=galaxy",
    "POSTGRES_DB=galaxy",
    "PGDATA=/var/lib/postgresql/data/pgdata"
  ]
  mounts {
    source = docker_volume.db_data.name
    target = "/var/lib/postgresql/data/pgdata"
    type   = "volume"
  }
  networks_advanced {
    name = local.network
  }
}

#resource "docker_image" "minio" {
#  name = "minio/minio"
#}
#
#resource "docker_container" "minio" {
#  name  = "minio"
#  image = docker_image.minio.latest
#  hostname = "object_store"
#  restart = "unless-stopped"
#  must_run = true
#  networks_advanced {
#    name = docker_network.galaxy_network.name
#  }
#  volumes {
#    volume_name = docker_volume.user_data.name
#  }
#  env = [
#    "MINIO_ACCESS_KEY=${var.object_store_access_key}",
#    "MINIO_SECRET_KEY=${var.object_store_secret_key}"
#  ]
#  command = ["server", "/data"]
#}