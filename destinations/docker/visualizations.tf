resource "docker_container" "visualizations" {
  image      = docker_image.galaxy_app.latest
  name       = "load-visualizations${local.name_suffix}"
  user       = "${local.app_user}:${local.app_group}"
  attach     = true
  must_run   = false
  entrypoint = ["bash", "-c", "mkdir -p '${local.managed_config_dir}/visualizations'; ${local.viz_curl_cmd}; "]
  mounts {
    source    = docker_volume.user_data.name
    target    = local.data_dir
    type      = "volume"
    read_only = false
  }
}

resource "docker_container" "visualizations-fix" {
  # TODO remove after https://github.com/galaxyproject/galaxy/issues/11057
  depends_on = [docker_container.visualizations]
  image      = docker_image.galaxy_app.latest
  name       = "load-visualizations-fix${local.name_suffix}"
  user       = "0"
  attach     = true
  must_run   = false
  entrypoint = ["bash", "-c", "apt-get install rename && rename -v 'y/A-Z/a-z/' '${local.managed_config_dir}/visualizations/'*"]
  mounts {
    source    = docker_volume.user_data.name
    target    = local.data_dir
    type      = "volume"
    read_only = false
  }
}