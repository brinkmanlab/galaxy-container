resource "docker_image" "galaxy_db" {
  name = local.db_image
}

resource "docker_container" "galaxy_db" {
  name       = "${local.db_name}${local.name_suffix}"
  image      = docker_image.galaxy_db.latest
  hostname   = local.db_name
  domainname = local.db_name
  restart    = "unless-stopped"
  must_run   = true
  user = "postgres"
  env = [
    "POSTGRES_USER=${local.db_conf.user}",
    "POSTGRES_PASSWORD=${local.db_conf.pass}",
    "POSTGRES_DB=${local.db_conf.name}",
    "PGDATA=/var/lib/postgresql/data/pgdata"
  ]
  mounts {
    source = docker_volume.db_data.name
    target = "/var/lib/postgresql/data"
    type   = "volume"
  }
  networks_advanced {
    name = local.network
    aliases = [local.db_name]
  }
}

resource "docker_container" "wait_for_db" {
  depends_on = [docker_container.galaxy_db]
  image = docker_image.galaxy_db.latest
  name = "wait_for_db"
  must_run = false
  attach = true
  command = ["bash", "-c", "until pg_isready -h '${local.db_conf.host}' -U '${local.db_conf.user}' -d '${local.db_conf.name}'; do sleep 1; done"]
  networks_advanced {
    name = local.network
  }
}

resource "docker_container" "init_db" {
  depends_on = [docker_container.wait_for_db]
  image = docker_image.galaxy_app.latest
  name = "${local.app_name}-init-db${local.name_suffix}"
  restart = "no"
  must_run = false
  attach = true
  command = ["/env_run.sh", "python3", "${local.root_dir}/scripts/create_db.py", "-c", "${local.config_dir}/galaxy.yml", "galaxy"]
  env = compact([
    "CWD=${local.root_dir}",
    "GALAXY_CONFIG_OVERRIDE_database_connection=${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}"
  ])
  networks_advanced {
    name = local.network
  }
}

resource "docker_container" "init_install_db" {
  depends_on = [docker_container.wait_for_db]
  image = docker_image.galaxy_app.latest
  name = "${local.app_name}-init-install-db${local.name_suffix}"
  user       = "${local.uwsgi_user}:${local.uwsgi_group}"
  restart = "no"
  must_run = false
  attach = true
  command = ["/env_run.sh", "python3", "${local.root_dir}/scripts/create_db.py", "-c", "${local.config_dir}/galaxy.yml", "install"]
  env = compact([
    "CWD=${local.root_dir}",
    "GALAXY_CONFIG_OVERRIDE_database_connection=${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}"
  ])
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
  depends_on = [docker_container.init_db, docker_container.init_install_db]
  image = docker_image.galaxy_app.latest
  name = "${local.app_name}-upgrade-db${local.name_suffix}"
  restart = "no"
  must_run = false
  attach = true
  command = ["/env_run.sh", "python3", "${local.root_dir}/scripts/manage_db.py", "upgrade", "-c", "${local.config_dir}/galaxy.yml"]
  env = compact([
    "CWD=${local.root_dir}",
    "GALAXY_CONFIG_OVERRIDE_database_connection=${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}"
  ])
  networks_advanced {
    name = local.network
  }
}