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

resource "docker_container" "init_db" {
  depends_on = [docker_container.galaxy_db]
  image = docker_image.galaxy_app.latest
  name = "${local.app_name}-init-db${local.name_suffix}"
  attach = true
  command = ["/env_run.sh", "python3", "${local.root_dir}/scripts/create_db.py", "-c", "${local.config_dir}/galaxy.yml", "galaxy"]
  env = compact([
    "CWD=${local.root_dir}",
    "GALAXY_CONFIG_OVERRIDE_database_connection=${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}"
  ])
}

resource "docker_container" "init_install_db" {
  depends_on = [docker_container.galaxy_db]
  image = docker_image.galaxy_app.latest
  name = "${local.app_name}-init-install-db${local.name_suffix}"
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
}

resource "docker_container" "upgrade_db" {
  depends_on = [docker_container.init_db, docker_container.init_install_db]
  image = docker_image.galaxy_app.latest
  name = "${local.app_name}-init-db${local.name_suffix}"
  attach = true
  command = ["/env_run.sh", "python3", "${local.root_dir}/scripts/manage_db.py", "upgrade", "-c", "${local.config_dir}/galaxy.yml"]
  env = compact([
    "CWD=${local.root_dir}",
    "GALAXY_CONFIG_OVERRIDE_database_connection=${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}"
  ])
}

resource "docker_container" "init_builds" {
  # if builds path is changed, init file with needed default row
  count = lookup(local.galaxy_conf, "builds_file_path", false) == false ? 0 : 1
  image = "alpine"
  name = "init-builds${local.name_suffix}"
  attach = true
  args = ["echo '?	unspecified (?)' > ${local.galaxy_conf["builds_file_path"]}"]
  mounts {
    source = docker_volume.user_data.name
    target = local.data_dir
    type   = "volume"
  }
}