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
          name              = "${var.app_name}-init-db"
          command           = ["/env_run.sh", "python3", "${var.root_dir}/scripts/manage_db.py", "upgrade"]
          image             = "${var.galaxy_app_image}:${var.image_tag}"
          image_pull_policy = var.debug ? "Always" : null
          env {
            name  = "GALAXY_CONFIG_OVERRIDE_database_connection"
            value = "${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}"
          }
          env {
            name  = "CWD"
            value = var.root_dir
          }
        }
        node_selector = {
          WorkClass = "service"
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  wait_for_completion = true
  timeouts {
    create = "10m"
  }
}