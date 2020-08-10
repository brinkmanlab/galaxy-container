# TODO https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md

resource "kubernetes_deployment" "galaxy_app" {
  depends_on = [var.depends]
  metadata {
    name = var.app_name
    namespace = var.instance
    labels = {
      App = var.app_name
      "app.kubernetes.io/name" = var.app_name
      "app.kubernetes.io/instance" = "${var.app_name}${var.name_suffix}"
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component" = "app"
      "app.kubernetes.io/part-of" = "galaxy"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  spec {
    replicas = 1
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
        init_container {
          name = "${var.app_name}-init-db"
          command = ['sh', '-c', '/galaxy/server/manage_db.sh upgrade']
          image = "${var.galaxy_app_image}:${var.image_tag}"
          env {
            name = "GALAXY_database_connection"
            value = "${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}"
          }
        }
        container {
          name = var.app_name
          image = "${var.galaxy_app_image}:${var.image_tag}"
          env {
            name = "GALAXY_database_connection"
            value = "${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}"
          }

          resources {
            limits {
              cpu = "2"
              memory = "2Gi"
            }
            requests {
              cpu = "1"
              memory = "1Gi"
            }
          }
          volume_mount {
            mount_path = var.data_dir
            name = "data"
          }
        }
        node_selector = {
          WorkClass = "service"
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = "user-data"
          }
        }
        # TODO Configure
        # https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#volume-2
      }
    }
  }
}

#resource "kubernetes_horizontal_pod_autoscaler" "galaxy_app" {
#  metadata {
#    name = var.app_name
#  }
#
#  spec {
#    max_replicas = 10
#    min_replicas = 1
#
#    scale_target_ref {
#      kind = "Deployment"
#      name = var.app_name
#    }
#  }
#}

# Register internal dns for web to discover app
resource "kubernetes_service" "galaxy_app" {
  metadata {
    name = var.app_name
    namespace = var.instance
  }
  spec {
    selector = {
      App = var.app_name
    }
    port {
      protocol = "TCP"
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"  # https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
  }
}