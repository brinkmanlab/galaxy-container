output "endpoint" {
  value = "galaxy-web:${data.null_data_source.api_ready.outputs.host_port}"
}

output "network" {
  value = local.network
}

output "host_port" {
  value = data.null_data_source.api_ready.outputs.host_port
}