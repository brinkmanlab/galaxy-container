resource "kubernetes_deployment" "tusd" {
  metadata {
    name      = local.tusd_name
    namespace = local.namespace.metadata.0.name
    labels    = {
      App                            = local.tusd_name
      "app.kubernetes.io/name"       = local.tusd_name
      "app.kubernetes.io/instance"   = local.tusd_name
      "app.kubernetes.io/version"    = var.tusd_tag
      "app.kubernetes.io/component"  = "tusd"
      "app.kubernetes.io/part-of"    = "galaxy"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  spec {
    min_ready_seconds      = 1
    revision_history_limit = 0
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        App = local.tusd_name
      }
    }
    template {
      metadata {
        labels = {
          App = local.tusd_name
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
          name              = local.tusd_name
          image             = "${local.tusd_image}:${var.tusd_tag}"
          image_pull_policy = var.debug ? "Always" : "IfNotPresent"

          args = [
            "-port", "1080",
            "-base-path", "/api/upload/resumable_upload",
            "-upload-dir", "${local.data_dir}/database/tmp",
            "-hooks-http", "http://${kubernetes_ingress.galaxy_web.status.0.load_balancer.0.ingress.0.hostname}/api/upload/hooks",
            "-hooks-http-forward-headers", "X-Api-Key,Cookie",
            "-hooks-enabled-events", "pre-create",
            "-behind-proxy",
          ]

          liveness_probe {
            http_get {
              path   = "/metrics"
              port   = "1080"
              scheme = "HTTP"
            }
          }

          resources {
            limits = {
              cpu    = "2"
              memory = "2Gi"
            }
            requests = {
              cpu    = "50m"
              memory = "500M"
            }
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
        # https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#volume-2
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "tusd" {
  metadata {
    name      = local.tusd_name
    namespace = kubernetes_deployment.tusd.metadata.0.namespace
  }

  spec {
    max_replicas = var.tusd_max_replicas
    min_replicas = 1

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = local.tusd_name
    }

    target_cpu_utilization_percentage = 50
  }
}

resource "kubernetes_service" "tusd" {
  metadata {
    name        = local.tusd_name
    namespace   = kubernetes_deployment.galaxy_web.metadata.0.namespace
  }
  spec {
    selector = {
      App = local.tusd_name
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 1080
      target_port = 1080
    }

    type = "ClusterIP" # https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer
  }
}