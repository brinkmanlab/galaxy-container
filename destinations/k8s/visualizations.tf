resource "kubernetes_job" "visualizations" {
  metadata {
    generate_name = "load-visualizations-"
    namespace = local.namespace.metadata.0.name
  }
  spec {
    template {
      metadata {}
      spec {
        security_context {
          run_as_user = local.uwsgi_uid
          run_as_group = local.uwsgi_gid
        }
        automount_service_account_token = false
        container {
          name              = "load-visualizations"
          command           = [ "bash", "-c", "mkdir -p '${local.managed_config_dir}/visualizations'; ${local.viz_curl_cmd}"]
          image             = "${local.galaxy_app_image}:${var.image_tag}"
          image_pull_policy = var.debug ? "Always" : null
          volume_mount {
            mount_path = local.data_dir
            name       = "data"
          }
        }
        node_selector = {
          WorkClass = "service"
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.user_data.metadata.0.name
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 1
  }
  wait_for_completion = true
  timeouts {
    create = "10m"
  }
}

resource "kubernetes_job" "visualizations-fix" {
  # TODO remove after https://github.com/galaxyproject/galaxy/issues/11057
  depends_on = [kubernetes_job.visualizations]
  metadata {
    generate_name = "load-visualizations-fix-"
    namespace = local.namespace.metadata.0.name
  }
  spec {
    template {
      metadata {}
      spec {
        security_context {
          run_as_user = 0
          run_as_group = local.uwsgi_gid
        }
        automount_service_account_token = false
        container {
          name              = "load-visualizations-fix"
          command           = ["bash", "-c", "apt-get install rename && rename -v 'y/A-Z/a-z/' '${local.managed_config_dir}/visualizations/'*"]
          image             = "${local.galaxy_app_image}:${var.image_tag}"
          image_pull_policy = var.debug ? "Always" : null
          volume_mount {
            mount_path = local.data_dir
            name       = "data"
          }
        }
        node_selector = {
          WorkClass = "service"
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.user_data.metadata.0.name
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 1
  }
  wait_for_completion = true
  timeouts {
    create = "10m"
  }
}