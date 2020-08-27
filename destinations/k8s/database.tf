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
        container {
          name              = "${local.app_name}-init-db"
          command           = ["/env_run.sh", "python3", "${local.root_dir}/scripts/create_db.py", "-c", "${local.config_dir}/galaxy.yml", "galaxy"]
          image             = "${local.galaxy_app_image}:${var.image_tag}"
          image_pull_policy = var.debug ? "Always" : null
          env {
            name  = "GALAXY_CONFIG_OVERRIDE_database_connection"
            value = "${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}"
          }
          env {
            name  = "CWD"
            value = local.root_dir
          }
        }
        node_selector = {
          WorkClass = "service"
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

resource "kubernetes_job" "init_install_db" {
  depends_on = [kubernetes_job.init_nfs]
  # Update galaxy database
  metadata {
    generate_name = "init-install-db-galaxy-"
    namespace     = local.instance
  }
  spec {
    template {
      metadata {}
      spec {
        security_context {
          run_as_user = 1000
          run_as_group = 1000
          fs_group = 1000
        }
        container {
          name              = "${local.app_name}-init-db"
          command           = ["/env_run.sh", "python3", "${local.root_dir}/scripts/create_db.py", "-c", "${local.config_dir}/galaxy.yml", "install"]
          image             = "${local.galaxy_app_image}:${var.image_tag}"
          image_pull_policy = var.debug ? "Always" : null
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

resource "kubernetes_job" "upgrade_db" {
  depends_on = [kubernetes_job.init_db, kubernetes_job.init_install_db]
  # Update galaxy database
  metadata {
    generate_name = "upgrade-db-galaxy-"
    namespace     = local.instance
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name              = "${local.app_name}-init-db"
          command           = ["/env_run.sh", "python3", "${local.root_dir}/scripts/manage_db.py", "upgrade", "-c", "${local.config_dir}/galaxy.yml"]
          image             = "${local.galaxy_app_image}:${var.image_tag}"
          image_pull_policy = var.debug ? "Always" : null
          env {
            name  = "GALAXY_CONFIG_OVERRIDE_database_connection"
            value = "${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}"
          }
          env {
            name  = "CWD"
            value = local.root_dir
          }
        }
        node_selector = {
          WorkClass = "service"
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