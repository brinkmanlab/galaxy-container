# TODO https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md

resource "kubernetes_deployment" "galaxy_app" {
  depends_on       = [kubernetes_job.upgrade_db, kubernetes_job.visualizations-fix] # TODO remove '-fix' after https://github.com/galaxyproject/galaxy/issues/11057
  wait_for_rollout = !var.debug
  metadata {
    name      = local.app_name
    namespace = local.namespace.metadata.0.name
    labels = {
      App                          = local.app_name
      "app.kubernetes.io/name"     = local.app_name
      "app.kubernetes.io/instance" = local.app_name
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component"  = "app"
      "app.kubernetes.io/part-of"    = "galaxy"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  spec {
    min_ready_seconds      = 10
    revision_history_limit = 0
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        App = local.app_name
      }
    }
    template {
      metadata {
        labels = {
          App = local.app_name
        }
      }
      spec {
        security_context {
          fs_group = local.app_gid
        }
        automount_service_account_token = false
        #image_pull_secrets {
        #  # TODO https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
        #  # docker hub is limiting anonymous access
        #  name = ""
        #}
        container {
          name              = local.app_name
          image             = "${local.galaxy_app_image}:${var.image_tag}"
          image_pull_policy = var.debug ? "Always" : "IfNotPresent"

          readiness_probe {
            http_get {
              path = "/api/version"
            }
            initial_delay_seconds = 2
            timeout_seconds       = 2
            failure_threshold     = 1
            success_threshold     = 3
            period_seconds        = 2
          }

          liveness_probe {
            http_get {
              path = "/api/version"
            }
            initial_delay_seconds = 2
            failure_threshold     = 3
            timeout_seconds       = 2
            success_threshold     = 1
            period_seconds        = 60
          }

          startup_probe {
            http_get {
              path = "/api/genomes"
              port = local.app_port
            }
            initial_delay_seconds = 5
            failure_threshold     = 30
            period_seconds        = 5
          }

          dynamic "env" {
            for_each = toset([for k, v in local.galaxy_conf : k]) # https://www.terraform.io/docs/language/meta-arguments/for_each.html#limitations-on-values-used-in-for_each
            content {
              name  = "GALAXY_CONFIG_OVERRIDE_${env.key}"
              value = local.galaxy_conf[env.key]
            }
          }

          dynamic "env" {
            for_each = local.job_conf # See worker.tf
            content {
              name  = env.key
              value = env.value
            }
          }

          resources {
            limits = {
              cpu    = "2"
              memory = "2Gi"
            }
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
              name = "config"
              read_only = true
              sub_path = volume_mount.key
            }
          }
          volume_mount {
            mount_path = "${local.config_dir}/macros"
            name       = "config-macros"
            read_only  = true
          }
          volume_mount {
            mount_path = "${local.root_dir}/visualizations"
            name       = "data"
            sub_path   = "visualizations"
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
        # https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#volume-2
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "galaxy_app" {
  metadata {
    name      = local.app_name
    namespace = kubernetes_deployment.galaxy_app.metadata.0.namespace
  }

  spec {
    max_replicas = var.app_max_replicas
    min_replicas = 1

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = local.app_name
    }

    target_cpu_utilization_percentage = 50
  }
}

# Register internal dns for web to discover app
resource "kubernetes_service" "galaxy_app" {
  metadata {
    name      = local.app_name
    namespace = kubernetes_deployment.galaxy_app.metadata.0.namespace
  }
  spec {
    selector = {
      App = local.app_name
    }
    port {
      protocol    = "TCP"
      port        = local.app_port
      target_port = local.app_port
    }

    type = "ClusterIP" # https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
  }
}