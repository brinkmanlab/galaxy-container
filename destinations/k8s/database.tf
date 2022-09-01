resource "kubernetes_job" "init_db" {
  # Update galaxy database
  metadata {
    generate_name = "init-db-galaxy-"
    namespace     = local.instance
  }
  spec {
    template {
      metadata {}
      spec {
        automount_service_account_token = false
        container {
          name              = "${local.app_name}-init-db"
          command           = ["python3", "${local.root_dir}/scripts/create_db.py", "--galaxy-config", "${local.config_dir}/galaxy.yml"]
          image             = "${local.galaxy_app_image}:${var.image_tag}"
          image_pull_policy = "Always"
          env {
            name  = "GALAXY_CONFIG_OVERRIDE_database_connection"
            value = "${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}"
          }
          env {
            name  = "CWD"
            value = local.root_dir
          }
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
  lifecycle {
    ignore_changes = all
  }
}

resource "kubernetes_job" "upgrade_db" {
  depends_on = [kubernetes_job.init_db]
  # Update galaxy database
  metadata {
    generate_name = "upgrade-db-galaxy-"
    namespace     = local.instance
  }
  spec {
    template {
      metadata {}
      spec {
        automount_service_account_token = false
        container {
          name              = "${local.app_name}-upgrade-db"
          command           = ["python3", "${local.root_dir}/scripts/manage_db.py", "--galaxy-config", "${local.config_dir}/galaxy.yml", "upgrade"]
          image             = "${local.galaxy_app_image}:${var.image_tag}"
          image_pull_policy = "Always"
          env {
            name  = "GALAXY_CONFIG_OVERRIDE_database_connection"
            value = "${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}"
          }
          env {
            name  = "CWD"
            value = local.root_dir
          }
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