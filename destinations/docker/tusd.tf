resource "docker_image" "tusd" {
  name = "${local.tusd_image}:${var.tusd_tag}"
}

resource "docker_container" "tusd" {
  depends_on = [docker_container.wait_for_app]
  name       = "${local.tusd_name}${local.name_suffix}"
  image      = docker_image.tusd.latest
  hostname   = local.tusd_name
  domainname = local.tusd_name
  restart    = "unless-stopped"
  must_run   = true

  command = [
    "-port", "1080",
    "-base-path", "/api/upload/resumable_upload",
    "-upload-dir", "${local.data_dir}/database/tmp",
    "-hooks-http", "http://${local.web_name}/api/upload/hooks",
    "-hooks-http-forward-headers", "X-Api-Key,Cookie",
    "-hooks-enabled-events", "pre-create",
    "-behind-proxy",
  ]

  networks_advanced {
    name    = local.network
    aliases = [local.tusd_name]
  }

  healthcheck {
    test         = ["CMD", "wget", "--spider", "http://localhost:1080/metrics"]
    start_period = "2s"
    timeout      = "2s"
    interval     = "10s"
    retries      = 3
  }

  mounts {
    source = docker_volume.user_data.name
    target = local.data_dir
    type   = "volume"
  }
}