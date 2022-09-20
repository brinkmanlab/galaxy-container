resource "kubernetes_deployment" "galaxy_celery_worker" {
  depends_on       = [kubernetes_job.upgrade_db]
  metadata {
    name      = local.celery_worker_name
    namespace = local.namespace.metadata.0.name
    labels    = {
      App                            = local.celery_worker_name
      "app.kubernetes.io/name"       = local.celery_worker_name
      "app.kubernetes.io/instance"   = local.celery_worker_name
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component"  = "celery_worker"
      "app.kubernetes.io/part-of"    = "galaxy"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  spec {
    min_ready_seconds      = 2
    revision_history_limit = 1
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        App = local.celery_worker_name
      }
    }
    template {
      metadata {
        labels = {
          App = local.celery_worker_name
        }
      }
      spec {
        security_context {
          run_as_user  = local.app_uid
          run_as_group = local.app_gid
        }
        service_account_name            = kubernetes_service_account.galaxy_app.metadata.0.name
        automount_service_account_token = true
        container {
          image             = "${local.galaxy_app_image}:${var.image_tag}"
          image_pull_policy = var.debug ? "Always" : "IfNotPresent"
          name              = local.celery_worker_name
          command           = [
            "celery",
            "--app", "galaxy.celery", "worker",
            "--concurrency", "2",
            "--loglevel", "INFO",
            "--pool", "threads",
            "--queues", "celery,galaxy.internal,galaxy.external"
          ]

          dynamic "env" {
            for_each = toset([for k, v in local.galaxy_conf : k])
            # https://www.terraform.io/docs/language/meta-arguments/for_each.html#limitations-on-values-used-in-for_each
            content {
              name  = "GALAXY_CONFIG_OVERRIDE_${env.key}"
              value = local.galaxy_conf[env.key]
            }
          }

          dynamic "env" {
            for_each = local.job_conf
            content {
              name  = env.key
              value = env.value
            }
          }

          dynamic "env" {
            for_each = var.extra_env
            content {
              name  = env.key
              value = tostring(env.value)
            }
          }

          env {
            name  = "CWD"
            value = local.root_dir
          }

          liveness_probe {
            exec {
              command = [
                "bash",
                "-c",
                "celery -A galaxy.celery inspect ping -d celery@$HOSTNAME"
              ]
            }
            initial_delay_seconds = 2
            failure_threshold     = 2
            timeout_seconds       = 2
            success_threshold     = 1
            period_seconds        = 200
          }

          resources {
            #limits = {
            #  cpu    = "2"
            #  memory = "6Gi"
            #}
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
          volume_mount {
            mount_path = local.data_dir
            name       = "data"
          }
          dynamic "volume_mount" {
            for_each = local.configs
            content {
              mount_path = "${local.config_dir}/${volume_mount.key}"
              name       = "config"
              read_only  = true
              sub_path   = volume_mount.key
            }
          }
          volume_mount {
            mount_path = "${local.config_dir}/macros"
            name       = "config-macros"
            read_only  = true
          }
          dynamic "volume_mount" {
            for_each = var.extra_mounts
            content {
              name       = volume_mount.key
              mount_path = volume_mount.value.path
              read_only  = volume_mount.value.read_only
            }
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
          config_map {
            name = kubernetes_config_map.galaxy_config.metadata.0.name
          }
        }
        volume {
          name = "config-macros"
          config_map {
            name = kubernetes_config_map.galaxy_config_macros.metadata.0.name
          }
        }
        dynamic "volume" {
          for_each = var.extra_mounts
          content {
            name = volume.key
            persistent_volume_claim {
              claim_name = volume.value.claim_name
            }
          }
        }
        # TODO Configure
        # https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#volume-2
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "galaxy_celery_worker" {
  metadata {
    name      = local.celery_worker_name
    namespace = kubernetes_deployment.galaxy_celery_worker.metadata.0.namespace
  }

  spec {
    max_replicas = var.celery_worker_max_replicas
    min_replicas = 1

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = local.celery_worker_name
    }
  }
}