# See https://blog.abyssale.com/shared-storage-volume-on-amazon/
# TODO Convert https://github.com/DrFaust92/terraform-kubernetes-ebs-csi-driver to EFS and also use for S3 CSI
resource "aws_efs_file_system" "user_data" {
  tags = {
    Name     = "${var.user_data_volume_name}${local.name_suffix}"
    Instance = local.instance
  }
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
}

resource "aws_efs_mount_target" "user_data" {
  count           = length(module.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.user_data.id
  security_groups = [aws_security_group.efs.id]
  subnet_id       = module.vpc.private_subnets[count.index]
}

resource "aws_security_group" "efs" {
  name        = "efs${local.name_suffix}"
  description = "EFS security group"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "NFS"
    cidr_blocks = [module.vpc.vpc_cidr_block]
    protocol    = "TCP"
    from_port   = 2049
    to_port     = 2049
  }
}
/*
resource "kubernetes_deployment" "efs" {
  depends_on = [module.eks.cluster_id]
  metadata {
    name = "efs-provisioner"
    namespace = "kube-system"
    labels = {
      App = "efs-provisioner"
    }
  }

  spec {
    replicas = 1
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        App = "efs-provisioner"
      }
    }
    template {
      metadata {
        labels = {
          App = "efs-provisioner"
        }
      }
      spec {
        service_account_name = "efs-provisioner"
        container {
          image = "quay.io/external_storage/efs-provisioner:latest"
          name = "efs-provisioner"
          env {
            name = "FILE_SYSTEM_ID"
            value = aws_efs_file_system.user_data.id
          }
          env {
            name = "AWS_REGION"
            value = data.aws_region.current.name
          }
          env {
            name = "DNS_NAME"
            value = aws_efs_file_system.user_data.dns_name
          }
          env {
            name = "PROVISIONER_NAME"
            value = "efs-provisioner"
          }

          resources {
            limits {
              cpu = "2"
              memory = "2Gi"
            }
            requests {
              cpu = "100m"
              memory = "1Gi"
            }
          }
          volume_mount {
            mount_path = "/persistentvolumes"
            name = "pv-volume"
          }
        }
        node_selector = {
          WorkClass = "service"
        }
        volume {
          name = "pv-volume"
          nfs {
            path = "/"
            server = aws_efs_file_system.user_data.dns_name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_account" "efs" {
  metadata {
    name = "efs-provisioner"
  }
}

resource "kubernetes_role" "efs" {
  metadata {
    name = "leader-locking-efs-provisioner"
  }
  rule {
    api_groups = [""]
    resources = ["endpoints"]
    verbs = ["get", "list", "watch", "create", "update", "patch"]
  }
}

resource "kubernetes_role_binding" "efs" {
  metadata {
    name = "leader-locking-efs-provisioner"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "leader-locking-efs-provisioner"
  }
  subject {
    kind = "ServiceAccount"
    name = "efs-provisioner"
  }
}

resource "kubernetes_cluster_role" "efs" {
  metadata {
    name = "leader-locking-efs-runner"
  }
  rule {
    api_groups = [""]
    resources = ["persistentvolumes"]
    verbs = ["get", "list", "watch", "create", "delete"]
  }
  rule {
    api_groups = [""]
    resources = ["persistentvolumeclaims"]
    verbs = ["get", "list", "watch", "update"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources = ["storageclasses"]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources = ["events"]
    verbs = ["create", "update", "patch"]
  }
  rule {
    api_groups = [""]
    resources = ["endpoints"]
    verbs = ["get", "list", "watch", "create", "update", "patch"]
  }
}

resource "kubernetes_cluster_role_binding" "efs" {
  metadata {
    name = "run-efs-provisioner"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "efs-provisioner-runner"
  }
  subject {
    kind = "ServiceAccount"
    name = "efs-provisioner"
  }
}

resource "kubernetes_storage_class" "user_data" {
  depends_on = [kubernetes_deployment.efs]
  metadata {
    name = "aws-efs"
  }
  storage_provisioner = "efs-provisioner"
}

resource "kubernetes_persistent_volume_claim" "user_data" {
  depends_on = [kubernetes_storage_class.user_data]
  metadata {
    name = "user-data"
    annotations = {
      "volume.beta.kubernetes.io/storage-class" = "aws-efs"
    }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1M"
      }
    }
  }
}
*/