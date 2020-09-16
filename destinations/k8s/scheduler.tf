# https://github.com/galaxyproject/galaxy/issues/8209

resource "kubernetes_pod" "scheduler" {
  count = var.scheduler_replicas
  metadata {
    name = "galaxy-workflow-scheduler${count.index}"
    namespace = local.instance
    labels = {
      App                          = "galaxy-workflow-scheduler"
      "app.kubernetes.io/name"     = "galaxy-workflow-scheduler"
      "app.kubernetes.io/instance" = "galaxy-workflow-scheduler${count.index}"
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component"  = "workflow-scheduler"
      "app.kubernetes.io/part-of"    = "galaxy"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  spec {
    restart_policy = "Always"
    security_context {
      run_as_user = local.uwsgi_uid
      run_as_group = local.uwsgi_gid
    }
    container {
      name              = "galaxy-workflow-scheduler${count.index}"
      image             = "${local.galaxy_app_image}:${var.image_tag}"
      image_pull_policy = var.debug ? "Always" : null
      command           = ["sh", "-c", "/env_run.sh python3 ${local.root_dir}/scripts/galaxy-main -c ${local.config_dir}/galaxy.yml --server-name='workflow-scheduler${count.index}' --log-file=/dev/stdout"]

      dynamic "env" {
        for_each = local.galaxy_conf
        content {
          name  = "GALAXY_CONFIG_OVERRIDE_${env.key}"
          value = env.value
        }
      }

      dynamic "env" {
        for_each = local.job_conf
        content {
          name  = env.key
          value = env.value
        }
      }

      env {
        name  = "CWD"
        value = local.root_dir
      }

      resources {
        limits {
          cpu    = "2"
          memory = "2Gi"
        }
        requests {
          cpu    = "1"
          memory = "1Gi"
        }
      }
      volume_mount {
        mount_path = local.data_dir
        name       = "data"
      }
      volume_mount {
        mount_path = "${local.config_dir}/macros"
        name = "config"
        read_only = true
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
    volume {
      name = "config"
      secret {
        secret_name = kubernetes_secret.galaxy_config.metadata.0.name
      }
    }
  }
}