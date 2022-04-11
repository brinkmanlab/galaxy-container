output "endpoint" {
  value = "galaxy-web:${data.null_data_source.api_ready.outputs.host_port}"
  description = "Docker network hostname for Galaxy front-end HTTP endpoint"
}

output "network" {
  value = local.network
  description = "Docker network Galaxy resources are attached to"
}

output "host_port" {
  value = data.null_data_source.api_ready.outputs.host_port
  description = "Host port Galaxy is being served on"
}