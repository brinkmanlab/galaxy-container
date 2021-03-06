locals {
  network = length(docker_network.galaxy_network) == 1 ? docker_network.galaxy_network[0].name : var.network
}

resource "docker_network" "galaxy_network" {
  count = var.network != "" ? 0 : 1
  name  = "galaxy_network${local.name_suffix}"
}

data "null_data_source" "api_ready" {
  depends_on = [docker_container.galaxy_web]
  inputs = {
    host_port = docker_container.galaxy_web.ports[0].external
  }
}