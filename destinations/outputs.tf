output "master_api_key" {
  value = local.master_api_key
  #sensitive = true
}

output "data_dir" { value = local.data_dir }
output "root_dir" { value = local.root_dir }
output "config_dir" { value = local.config_dir }
output "galaxy_web_image" { value = local.galaxy_web_image }
output "galaxy_app_image" { value = local.galaxy_app_image }
output "db_image" { value = local.db_image }
output "galaxy_root_volume_name" { value = local.galaxy_root_volume_name }
output "user_data_volume_name" { value = local.user_data_volume_name }
output "db_data_volume_name" { value = local.db_data_volume_name }
output "web_name" { value = local.web_name }
output "app_name" { value = local.app_name }
output "worker_name" { value = local.worker_name }
output "db_name" { value = local.db_name }
output "app_port" { value = local.app_port }
output "app_uid" { value = local.app_uid }
output "app_gid" { value = local.app_gid }
output "id_secret" { value = local.id_secret }
output "db_conf" { value = local.db_conf }