output "master_api_key" {
  value = lookup(local.galaxy_conf, "master_api_key")
}