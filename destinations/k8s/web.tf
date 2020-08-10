# TODO https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md

resource "kubernetes_deployment" "galaxy_web" {
  depends_on = [var.depends]
  metadata {
    name = var.web_name
    namespace = var.instance
    labels = {
      App = var.web_name
      "app.kubernetes.io/name" = var.web_name
      "app.kubernetes.io/instance" = "${var.web_name}${var.name_suffix}"
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component" = "web"
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
        App = var.web_name
      }
    }
    template {
      metadata {
        labels = {
          App = var.web_name
        }
      }
      spec {
        container {
          image = "${var.galaxy_web_image}:${var.image_tag}"
          name = var.web_name
          #env {}

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

#resource "kubernetes_horizontal_pod_autoscaler" "galaxy_web" {
#  for_each = local.profiles
#  metadata {
#    name = "galaxy{var.name_suffix}"
#  }
#
#  spec {
#    max_replicas = 10
#    min_replicas = 1
#
#    scale_target_ref {
#      kind = "Deployment"
#      name = "${var.web_name}${var.name_suffix}"
#    }
#  }
#}


resource "kubernetes_service" "galaxy_web" {
  metadata {
    name = var.web_name
    namespace = var.instance
  }
  spec {
    selector = {
      App = var.web_name
    }
    port {
      protocol = "TCP"
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"  # https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer
  }
}