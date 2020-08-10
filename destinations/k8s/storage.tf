resource "kubernetes_persistent_volume" "user_data" {
  metadata {
    name = "galaxy-user-data"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    capacity = {
      storage = "1Ti"
    }
    persistent_volume_source {
      nfs {
        path = "/${var.instance}/galaxy/"
        server = var.nfs_server
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "user_data" {
  metadata {
    name = "galaxy-user-data"
    namespace = var.instance
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "500Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.user_data.metadata.0.name
  }
}