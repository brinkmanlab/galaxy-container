# TODO https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md

resource "kubernetes_deployment" "galaxy_web" {
  depends_on       = [kubernetes_service.galaxy_app]
  wait_for_rollout = ! var.debug
  metadata {
    name      = local.web_name
    namespace = local.instance
    labels = {
      App                          = local.web_name
      "app.kubernetes.io/name"     = local.web_name
      "app.kubernetes.io/instance" = local.web_name
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component"  = "web"
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
        App = local.web_name
      }
    }
    template {
      metadata {
        labels = {
          App = local.web_name
        }
      }
      spec {
        security_context {
          fs_group = 1000
        }
        container {
          #security_context {
          #  run_as_user = 1000
          #  run_as_group = 1000
          #}
          image             = "${local.galaxy_web_image}:${var.image_tag}"
          image_pull_policy = var.debug ? "Always" : null
          name              = local.web_name
          dynamic "env" {
            for_each = local.master_api_key_conf
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

resource "kubernetes_horizontal_pod_autoscaler" "galaxy_web" {
  metadata {
    name      = local.web_name
    namespace = local.instance
  }

  spec {
    max_replicas = 10
    min_replicas = 1

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = local.web_name
    }
  }
}


resource "kubernetes_service" "galaxy_web" {
  metadata {
    name      = local.web_name
    namespace = local.instance
  }
  spec {
    selector = {
      App = local.web_name
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer" # https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer
  }
}