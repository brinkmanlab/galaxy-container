resource "docker_service" "web" {
  name = local.web_name

  task_spec {
    container_spec {
      image = local.galaxy_web_image
      hostname   = local.web_name

      env = ["master_api_key=${local.master_api_key}"]

      healthcheck {
        test         = ["CMD", "wget", "--spider", "http://localhost/health"]
        start_period = "2s"
        timeout      = "2s"
        interval     = "10s"
        retries      = 3
      }
    }
  }

  endpoint_spec {
    ports {
      target_port = "8080"
    }
  }
}