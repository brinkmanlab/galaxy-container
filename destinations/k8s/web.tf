# TODO https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md

resource "kubernetes_deployment" "galaxy_web" {
  depends_on       = [kubernetes_service.galaxy_app, kubernetes_service.tusd]
  metadata {
    name      = local.web_name
    namespace = local.namespace.metadata.0.name
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
    min_ready_seconds      = 1
    revision_history_limit = 0
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
          fs_group = local.app_gid
        }
        automount_service_account_token = false
        container {
          #security_context {
          #  run_as_user = local.app_uid
          #  run_as_group = local.app_gid
          #}
          image             = "${local.galaxy_web_image}:${var.image_tag}"
          image_pull_policy = var.debug ? "Always" : "IfNotPresent"
          name              = local.web_name
          env {
            name  = "master_api_key"
            value = local.master_api_key
          }

          liveness_probe {
            http_get {
              path   = "/health"
              port   = "80"
              scheme = "HTTP"
            }
          }

          resources {
            limits = {
              cpu    = "2"
              memory = "2Gi"
            }
            requests = {
              cpu    = "200m"
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
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "galaxy_web" {
  metadata {
    name      = local.web_name
    namespace = kubernetes_deployment.galaxy_web.metadata.0.namespace
  }

  spec {
    max_replicas = var.web_max_replicas
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
    name        = local.web_name
    namespace   = kubernetes_deployment.galaxy_web.metadata.0.namespace
  }
  spec {
    selector = {
      App = local.web_name
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }

    type = "NodePort" # https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer
  }
}

resource "kubernetes_ingress" "galaxy_web" {
  wait_for_load_balancer = true
  metadata {
    name        = local.web_name
    namespace   = kubernetes_deployment.galaxy_web.metadata.0.namespace
    annotations = var.lb_annotations
  }
  spec {
    backend {
      service_name = kubernetes_service.galaxy_web.metadata.0.name
      service_port = 80
    }
    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = kubernetes_service.galaxy_web.metadata.0.name
            service_port = 80
          }
        }
      }
    }
  }
}