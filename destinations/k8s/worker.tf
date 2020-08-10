# TODO https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md

resource "kubernetes_deployment" "galaxy_worker" {
  depends_on = [var.depends]
  metadata {
    name = var.worker_name
    namespace = var.instance
    labels = {
      App = var.worker_name
      "app.kubernetes.io/name" = var.worker_name
      "app.kubernetes.io/instance" = "${var.worker_name}${var.name_suffix}"
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component" = "worker"
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
        App = var.worker_name
      }
    }
    template {
      metadata {
        labels = {
          App = var.worker_name
        }
      }
      spec {
        service_account_name = kubernetes_service_account.galaxy_worker.metadata.0.name
        container {
          image = "${var.galaxy_app_image}:${var.image_tag}"
          name = var.worker_name
          env {
            name = "K8S_ENABLED"
            value = "True"
          }
          env {
            name = "K8S_NAMESPACE"
            value = var.instance
          }
          env {
            name = "K8S_VOLUMES"
            value = "${kubernetes_persistent_volume_claim.user_data.metadata.0.name}:${var.data_dir}"
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
            claim_name = kubernetes_persistent_volume_claim.user_data.metadata.0.name
          }
        }
        # TODO Configure
        # https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#volume-2
      }
    }
  }
}

#resource "kubernetes_horizontal_pod_autoscaler" "galaxy_worker" {
#  for_each = local.profiles
#  metadata {
#    name = var.worker_name
#    namespace = var.instance
#  }
#
#  spec {
#    max_replicas = 10
#    min_replicas = 1
#
#    scale_target_ref {
#      kind = "Deployment"
#      name = var.worker_name
#    }
#  }
#}

resource "kubernetes_service_account" "galaxy_worker" {
  metadata {
    name = var.worker_name
    namespace = var.instance
    labels = {
      "app.kubernetes.io/name" = var.worker_name
      "app.kubernetes.io/instance" = "${var.worker_name}${var.name_suffix}"
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component" = "worker"
      "app.kubernetes.io/part-of" = "galaxy"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_role" "galaxy_worker" {
  metadata {
    name = var.worker_name
    namespace = var.instance
    labels = {
      "app.kubernetes.io/name" = var.worker_name
      "app.kubernetes.io/instance" = "${var.worker_name}${var.name_suffix}"
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component" = "worker"
      "app.kubernetes.io/part-of" = "galaxy"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  rule {
    api_groups = [""]
    resources = ["pods", "pods/log"]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["batch", "extensions"]
    resources = ["jobs"]
    verbs = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding" "galaxy_worker" {
  metadata {
    name = var.worker_name
    namespace = var.instance
    labels = {
      "app.kubernetes.io/name" = var.worker_name
      "app.kubernetes.io/instance" = "${var.worker_name}${var.name_suffix}"
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component" = "worker"
      "app.kubernetes.io/part-of" = "galaxy"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = kubernetes_role.galaxy_worker.metadata.0.name
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.galaxy_worker.metadata.0.name
    api_group = "rbac.authorization.k8s.io"
  }
}