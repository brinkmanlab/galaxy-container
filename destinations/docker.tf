locals {
  region     = var.region
  containers = {}
  object_store_host = ""
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "galaxy_app" {
  name = "galaxy_app:${var.image_tag}"
}

resource "docker_image" "galaxy_web" {
  name = "galaxy_web:${var.image_tag}"
}

resource "docker_image" "galaxy_worker" {
  name = "galaxy_app:${var.image_tag}"
}

resource "docker_image" "galaxy_db" {
  name = "postgres:alpine"
}

resource "docker_network" "galaxy_network" {
  name = "galaxy_network${local.name_suffix}"
}

resource "docker_volume" "galaxy_root" {
  name = "${local.ansible.volumes.galaxy_root.name}${local.name_suffix}"
}

resource "docker_volume" "db_data" {
  name = "${local.ansible.volumes.db_data.name}${local.name_suffix}"
}

resource "docker_container" "galaxy_app" {
  name       = "${local.ansible.containers.app.name}${local.name_suffix}"
  image      = docker_image.galaxy_app.latest
  hostname   = "galaxy_app"
  domainname = "galaxy_app"
  restart    = "unless-stopped"
  must_run   = true
  user       = "galaxy:galaxy"
  networks_advanced {
    name = docker_network.galaxy_network.name
  }
  mounts {
    source = docker_volume.user_data.name
    target = local.ansible.paths.data
    type   = "volume"
  }
  depends_on = [docker_container.galaxy_db]
}

resource "docker_container" "galaxy_web" {
  name       = "${local.ansible.containers.web.name}${local.name_suffix}"
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
    name = docker_network.galaxy_network.name
  }
  mounts {
    source = docker_volume.user_data.name
    target = local.ansible.paths.data
    type   = "volume"
  }
}

resource "docker_container" "galaxy_worker" {
  name  = "${local.ansible.containers.worker.name}${local.name_suffix}"
  image = docker_image.galaxy_worker.latest
  # https://docs.galaxyproject.org/en/master/admin/scaling.html#uwsgi-for-web-serving-and-webless-galaxy-applications-as-job-handlers
  command    = ["/env_run.sh", "python3", "${local.ansible.paths.root}/scripts/galaxy-main", "-c", "${local.ansible.paths.config}/galaxy.yml", "--server-name=${local.ansible.containers.worker.name}${local.name_suffix}", "--log-file=/dev/stdout", "--attach-to-pool=job-handlers"]
  # /env_run.sh "python3" "/srv/galaxy/scripts/galaxy-main" "-c" "/srv/galaxy/config/galaxy.yml" "--server-name=$HOSTNAME" "--log-file=/dev/stdout" --attach-to-pool=job-handlers
  hostname   = "galaxy_worker"
  domainname = "galaxy_worker"
  restart    = "unless-stopped"
  must_run   = true
  user       = "galaxy:galaxy"
  group_add  = ["969"]
  env        = compact([
    local.name_suffix == "" ? "" : "DOCKER_VOLUME_MOUNTS='${ local.ansible.volumes.galaxy_root.name }${ local.name_suffix }:$galaxy_root:ro,${ local.ansible.volumes.user_data.name }${ local.name_suffix }:/data:rw,$working_directory:rw'",
    "CWD=${local.ansible.paths.root}",
    "DEFAULT_CONTAINER_ID=${docker_image.galaxy_worker.latest}",
  ])
  mounts {
    target = "/var/run/docker.sock"
    source = "/var/run/docker.sock"
    type   = "bind"
  }
  mounts {
    source = docker_volume.user_data.name
    target = local.ansible.paths.data
    type   = "volume"
  }
  mounts {
    source = docker_volume.galaxy_root.name #"${local.ansible.volumes.galaxy_root.name}${local.name_suffix}"
    target = local.ansible.paths.root
    type   = "volume"
  }
  networks_advanced {
    name = docker_network.galaxy_network.name
  }
  depends_on = [docker_container.galaxy_db]
}

resource "docker_container" "galaxy_db" {
  name       = "${local.ansible.containers.db.name}${local.name_suffix}"
  image      = docker_image.galaxy_db.latest
  hostname   = "galaxy_db"
  domainname = "galaxy_db"
  restart    = "unless-stopped"
  must_run   = true
  env        = [
    "POSTGRES_PASSWORD=${local.db_password}",
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
    name = docker_network.galaxy_network.name
  }
}

### Minio user_data store ###

resource "docker_volume" "user_data" {
  name = "${local.ansible.volumes.user_data.name}${local.name_suffix}"
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

# Load misc containers

resource "docker_image" "galaxy_images" {
  for_each = local.containers
  name     = each.value
}

resource "docker_container" "galaxy_containers" {
  for_each = local.containers
  name     = "${each.key}${local.name_suffix}"
  image    = docker_image.galaxy_images[each.key].latest
  hostname = each.key
  restart  = "unless-stopped"
  must_run = true
  networks_advanced {
    name = docker_network.galaxy_network.name
  }
}