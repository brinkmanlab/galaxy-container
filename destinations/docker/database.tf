resource "docker_image" "galaxy_db" {
  name = local.db_image
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