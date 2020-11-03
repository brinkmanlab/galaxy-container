resource "kubernetes_job" "init_nfs" {
  # Make directories on NFS for instance
  metadata {
    generate_name = "init-nfs-galaxy-"
    namespace     = local.instance
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "init-nfs-galaxy"
          image   = "alpine"
          command = ["install", "-v", "-d", "-m", "0777", "-o", local.uwsgi_uid, "-g", local.uwsgi_gid, "${local.data_dir}/${local.instance}/galaxy/"]
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
          nfs {
            path   = "/"
            server = var.nfs_server
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  wait_for_completion = true
  timeouts {
    create = "10m"
  }
}

resource "kubernetes_storage_class" "nfs" {
  # This exists to get around a bug preventing setting an empty storage_class_name
  # https://github.com/hashicorp/terraform-provider-kubernetes/issues/872
  metadata {
    name = "filestore"
  }
  reclaim_policy      = "Retain"
  storage_provisioner = "nfs"
}

resource "kubernetes_persistent_volume" "user_data" {
  depends_on = [kubernetes_job.init_nfs]
  metadata {
    name = "galaxy-${local.user_data_volume_name}${local.name_suffix}"
    labels = {
      "app.kubernetes.io/name"     = "galaxy-${local.user_data_volume_name}"
      "app.kubernetes.io/instance" = "galaxy-${local.user_data_volume_name}"
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component"  = "pv"
      "app.kubernetes.io/part-of"    = "galaxy"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    capacity = {
      storage = "1Ti"
    }
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = kubernetes_storage_class.nfs.metadata[0].name
    persistent_volume_source {
      nfs {
        path      = "/${local.instance}/galaxy/"
        server    = var.nfs_server
        read_only = false
      }
    }
    #mount_options = ["all_squash", "anonuid=1000", "anongid=1000"]
  }
}

resource "kubernetes_persistent_volume_claim" "user_data" {
  metadata {
    name      = local.user_data_volume_name
    namespace = local.namespace.metadata.0.name
    labels = {
      "app.kubernetes.io/name"     = "galaxy-${local.user_data_volume_name}"
      "app.kubernetes.io/instance" = "galaxy-${local.user_data_volume_name}"
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component"  = "pvc"
      "app.kubernetes.io/part-of"    = "galaxy"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "500Gi"
      }
    }
    storage_class_name = kubernetes_storage_class.nfs.metadata[0].name
    #selector {
    #  match_labels = {
    #    name = kubernetes_persistent_volume.user_data.metadata.0.name
    #  }
    #}
    volume_name = kubernetes_persistent_volume.user_data.metadata.0.name
  }
}