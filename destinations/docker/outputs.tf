output "endpoint" {
  value = data.null_data_source.api_ready.outputs.endpoint
}

output "network" {
  value = local.network
}

output "host_port" {
  value = docker_container.galaxy_web.ports[0].external
}