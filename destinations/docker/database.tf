resource "docker_image" "galaxy_db" {
  name = local.db_image
}

resource "docker_volume" "db_data" {
  name = "${local.db_data_volume_name}${local.name_suffix}"
}

resource "docker_container" "galaxy_db" {
  name       = "${local.db_name}${local.name_suffix}"
  image      = docker_image.galaxy_db.latest
  hostname   = local.db_name
  domainname = local.db_name
  restart    = "unless-stopped"
  must_run   = true
  env = [
    "POSTGRES_PASSWORD=${local.db_conf.pass}",
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

resource "docker_container" "init_db" {
  depends_on = [docker_container.galaxy_db]
  image = docker_image.galaxy_app.latest
  name = "${local.app_name}-init-db"
  command = ["/env_run.sh", "python3", "${local.root_dir}/scripts/create_db.py", "-c", "${local.config_dir}/galaxy.yml", "galaxy"]
  restart = "on-failure"
  must_run = false
  start = true
  attach = true

  env = [
    "GALAXY_CONFIG_OVERRIDE_database_connection=${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}",
    "CWD=${local.root_dir}"
  ]

  networks_advanced {
    name = local.network
  }
}

resource "docker_container" "init_install_db" {
  depends_on = [docker_container.init_db]
  image = docker_image.galaxy_app.latest
  name = "${local.app_name}-init-install-db"
  command = ["/env_run.sh", "python3", "${local.root_dir}/scripts/create_db.py", "-c", "${local.config_dir}/galaxy.yml", "install"]
  restart = "on-failure"
  must_run = false
  start = true
  attach = true

  env = [
    "GALAXY_CONFIG_OVERRIDE_database_connection=${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}",
    "CWD=${local.root_dir}"
  ]

  mounts {
    source = docker_volume.user_data.name
    target = local.data_dir
    type   = "volume"
  }

  networks_advanced {
    name = local.network
  }
}

resource "docker_container" "upgrade_db" {
  depends_on = [docker_container.init_install_db]
  image = docker_image.galaxy_app.latest
  name = "${local.app_name}-upgrade-db"
  command = ["/env_run.sh", "python3", "${local.root_dir}/scripts/manage_db.py", "upgrade", "-c", "${local.config_dir}/galaxy.yml"]
  restart = "on-failure"
  must_run = false
  start = true
  attach = true

  env = [
    "GALAXY_CONFIG_OVERRIDE_database_connection=${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}",
    "CWD=${local.root_dir}"
  ]

  networks_advanced {
    name = local.network
  }
}