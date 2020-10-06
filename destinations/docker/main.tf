locals {
  network = length(docker_network.galaxy_network) == 1 ? docker_network.galaxy_network[0].name : var.network
}

resource "docker_volume" "galaxy_root" {
  name = "${local.galaxy_root_volume_name}${local.name_suffix}"
}

resource "docker_volume" "user_data" {
  name = "${local.user_data_volume_name}${local.name_suffix}"
}

resource "docker_network" "galaxy_network" {
  count = var.network != "" ? 0 : 1
  name  = "galaxy_network${local.name_suffix}"
}