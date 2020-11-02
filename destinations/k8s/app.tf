# TODO https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md

resource "kubernetes_deployment" "galaxy_app" {
  depends_on       = [kubernetes_job.upgrade_db]
  wait_for_rollout = ! var.debug
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
    replicas          = 1
    min_ready_seconds = 10
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
          fs_group = local.uwsgi_gid
        }
        #image_pull_secrets {
        #  # TODO https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
        #  # docker hub is limiting anonymous access
        #  name = ""
        #}
        container {
          name              = local.app_name
          image             = "${local.galaxy_app_image}:${var.image_tag}"
          image_pull_policy = var.debug ? "Always" : null

          readiness_probe {
            exec {
              command = ["uwping", "uwsgi://localhost:${local.uwsgi_port}/api/version"]
            }
            initial_delay_seconds = 2
            timeout_seconds = 2
            period_seconds = 2
          }

          liveness_probe {
            exec {
              command = ["uwping", "uwsgi://localhost:${local.uwsgi_port}/api/version"]
            }
            initial_delay_seconds = 2
            failure_threshold = 3
            timeout_seconds = 2
            success_threshold = 1
            period_seconds = 10
          }

          dynamic "env" {
            for_each = local.galaxy_conf
            content {
              name  = "GALAXY_CONFIG_OVERRIDE_${env.key}"
              value = env.value
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
          volume_mount {
            mount_path = "${local.root_dir}/visualizations"
            name = "data"
            sub_path = "visualizations"
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
        # TODO Configure
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
    max_replicas = 10
    min_replicas = 1

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = local.app_name
    }
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
      port        = local.uwsgi_port
      target_port = local.uwsgi_port
    }

    type = "ClusterIP" # https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
  }
}