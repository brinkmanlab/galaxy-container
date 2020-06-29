locals {
  region = ""
  containers = {}
}

provider "docker" {
  host = "tcp://127.0.0.1:2376/"
}

resource "docker_image" "galaxy_app" {
  name = "galaxy_app:latest"
}

resource "docker_image" "galaxy_web" {
  name = "galaxy_web:latest"
}

resource "docker_image" "galaxy_worker" {
  name = "galaxy_app:latest"
}

resource "docker_network" "galaxy_network" {
  name = "galaxy_network"
}

resource "docker_container" "galaxy_app" {
  name  = "galaxy_app"
  image = docker_image.galaxy_app.latest
  hostname = "galaxy_app"
  domainname = "galaxy_app"
  restart = "unless-stopped"
  must_run = true
  networks_advanced {
    name = docker_network.galaxy_network.name
  }
}

resource "docker_container" "galaxy_web" {
  name  = "galaxy_web"
  image = docker_image.galaxy_web.latest
  hostname = "galaxy_web"
  domainname = "galaxy_web"
  restart = "unless-stopped"
  must_run = true
  ports {
    external = 80
    internal = 80
  }
  networks_advanced {
    name = docker_network.galaxy_network.name
  }
  mounts {
    source = docker_volume.user_data.name
    target = local.ansible.galaxy.paths.data
    type = "volume"
  }
}

resource "docker_container" "galaxy_worker" {
  name  = "galaxy_worker"
  image = docker_image.galaxy_worker.latest
  # https://docs.galaxyproject.org/en/master/admin/scaling.html#uwsgi-for-web-serving-and-webless-galaxy-applications-as-job-handlers
  command = ["python", "${local.ansible.galaxy.paths.root}/scripts/galaxy-main", "-c", "${local.ansible.galaxy.paths.config}/galaxy.yml", "--server-name=$HOSTNAME", "--log-file=/dev/stdout"]
  hostname = "galaxy_worker"
  domainname = "galaxy_worker"
  restart = "unless-stopped"
  must_run = true
  mounts {
    target = "/var/run/docker.sock"
    source = "/var/run/docker.sock"
    type = "bind"
  }
  mounts {
    source = docker_volume.user_data.name
    target = local.ansible.galaxy.paths.data
    type = "volume"
  }
  mounts {
    source = local.ansible.volumes.galaxy_root.name
    target = local.ansible.galaxy.paths.root
    type = "volume"
  }
  networks_advanced {
    name = docker_network.galaxy_network.name
  }
}

### Minio user_data store ###

resource "docker_volume" "user_data" {
  name = local.ansible.volumes.user_data.name
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
  name = each.value
}

resource "docker_container" "galaxy_containers" {
  for_each = local.containers
  name  = each.key
  image = docker_image.galaxy_images[each.key].latest
  hostname = each.key
  restart = "unless-stopped"
  must_run = true
  networks_advanced {
    name = docker_network.galaxy_network.name
  }
}