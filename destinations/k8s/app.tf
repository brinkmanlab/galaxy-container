# TODO https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md

resource "kubernetes_deployment" "galaxy_app" {
  depends_on       = [kubernetes_job.init_db]
  wait_for_rollout = ! var.debug
  metadata {
    name      = var.app_name
    namespace = local.instance
    labels = {
      App                          = var.app_name
      "app.kubernetes.io/name"     = var.app_name
      "app.kubernetes.io/instance" = var.app_name
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component"  = "app"
      "app.kubernetes.io/part-of"    = "galaxy"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  spec {
    replicas          = 1
    min_ready_seconds = 1
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        App = var.app_name
      }
    }
    template {
      metadata {
        labels = {
          App = var.app_name
        }
      }
      spec {
        security_context {
          fs_group = 1000
        }
        container {
          name              = var.app_name
          image             = "${var.galaxy_app_image}:${var.image_tag}"
          image_pull_policy = var.debug ? "Always" : null

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
            mount_path = var.data_dir
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
        # TODO Configure
        # https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#volume-2
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "galaxy_app" {
  metadata {
    name      = var.app_name
    namespace = local.instance
  }

  spec {
    max_replicas = 10
    min_replicas = 1

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = var.app_name
    }
  }
}

# Register internal dns for web to discover app
resource "kubernetes_service" "galaxy_app" {
  metadata {
    name      = var.app_name
    namespace = local.instance
  }
  spec {
    selector = {
      App = var.app_name
    }
    port {
      protocol    = "TCP"
      port        = var.uwsgi_port
      target_port = var.uwsgi_port
    }

    type = "ClusterIP" # https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
  }
}