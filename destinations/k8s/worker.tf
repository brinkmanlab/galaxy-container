# TODO https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md
locals {
  job_conf = {
    K8S_ENABLED   = "True"
    K8S_NAMESPACE = local.instance
    K8S_VOLUMES   = "${kubernetes_persistent_volume_claim.user_data.metadata.0.name}:${local.data_dir}"
  }
}


resource "kubernetes_deployment" "galaxy_worker" {
  depends_on       = [kubernetes_job.init_db]
  wait_for_rollout = ! var.debug
  metadata {
    name      = local.worker_name
    namespace = local.instance
    labels = {
      App                          = local.worker_name
      "app.kubernetes.io/name"     = local.worker_name
      "app.kubernetes.io/instance" = local.worker_name
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component"  = "worker"
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
        App = local.worker_name
      }
    }
    template {
      metadata {
        labels = {
          App = local.worker_name
        }
      }
      spec {
        security_context {
          fs_group = 1000
        }
        service_account_name            = kubernetes_service_account.galaxy_worker.metadata.0.name
        automount_service_account_token = true
        container {
          image             = "${local.galaxy_app_image}:${var.image_tag}"
          image_pull_policy = var.debug ? "Always" : null
          name              = local.worker_name
          command           = ["sh", "-c", "/env_run.sh python3 ${local.root_dir}/scripts/galaxy-main -c ${local.config_dir}/galaxy.yml --server-name=$HOSTNAME --log-file=/dev/stdout --attach-to-pool=job-handlers"]

          dynamic "env" {
            for_each = local.galaxy_conf
            content {
              name  = "GALAXY_CONFIG_OVERRIDE_${env.key}"
              value = env.value
            }
          }

          dynamic "env" {
            for_each = local.job_conf
            content {
              name  = env.key
              value = env.value
            }
          }

          env {
            name  = "CWD"
            value = local.root_dir
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

resource "kubernetes_horizontal_pod_autoscaler" "galaxy_worker" {
  metadata {
    name      = local.worker_name
    namespace = local.instance
  }

  spec {
    max_replicas = 10
    min_replicas = 1

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = local.worker_name
    }
  }
}

resource "kubernetes_service_account" "galaxy_worker" {
  metadata {
    name      = local.worker_name
    namespace = local.instance
    labels = {
      "app.kubernetes.io/name"     = local.worker_name
      "app.kubernetes.io/instance" = local.worker_name
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component"  = "worker"
      "app.kubernetes.io/part-of"    = "galaxy"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_role" "galaxy_worker" {
  metadata {
    name      = local.worker_name
    namespace = local.instance
    labels = {
      "app.kubernetes.io/name"     = local.worker_name
      "app.kubernetes.io/instance" = local.worker_name
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component"  = "worker"
      "app.kubernetes.io/part-of"    = "galaxy"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["batch", "extensions"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding" "galaxy_worker" {
  metadata {
    name      = local.worker_name
    namespace = local.instance
    labels = {
      "app.kubernetes.io/name"     = local.worker_name
      "app.kubernetes.io/instance" = local.worker_name
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component"  = "worker"
      "app.kubernetes.io/part-of"    = "galaxy"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.galaxy_worker.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.galaxy_worker.metadata.0.name
    api_group = "" #"rbac.authorization.k8s.io"
  }
}