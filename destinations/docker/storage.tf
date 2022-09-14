resource "docker_volume" "galaxy_root" {
  name = "${local.galaxy_root_volume_name}${local.name_suffix}"
}

resource "docker_volume" "user_data" {
  name = "${local.user_data_volume_name}${local.name_suffix}"
}

resource "docker_volume" "db_data" {
  name = "${local.db_data_volume_name}${local.name_suffix}"
}

resource "docker_volume" "mq_data" {
  name = "${local.db_data_volume_name}${local.name_suffix}"
}