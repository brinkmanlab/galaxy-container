locals {
  namespace = var.namespace != null ? var.namespace : kubernetes_namespace.instance[0]
}

resource "kubernetes_namespace" "instance" {
  count = var.namespace == null ? 1 : 0
  metadata {
    name = local.instance
  }
}

resource "kubernetes_config_map" "galaxy_config" {
  metadata {
    name      = "galaxy-config"
    namespace = local.namespace.metadata.0.name
  }
  data = local.configs
}