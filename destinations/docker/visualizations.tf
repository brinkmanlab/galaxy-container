resource "docker_container" "visualizations" {
  image = docker_image.galaxy_app.latest
  name = "load-visualizations${local.name_suffix}"
  user       = "${local.uwsgi_user}:${local.uwsgi_group}"
  attach = true
  must_run = false
  entrypoint = ["bash", "-c", "mkdir -p '${local.managed_config_dir}/visualizations'; ${local.viz_curl_cmd}"]
  mounts {
    source = docker_volume.user_data.name
    target = local.data_dir
    type   = "volume"
    read_only = false
  }
}