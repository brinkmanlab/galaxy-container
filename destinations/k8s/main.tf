locals {
  namespace = var.namespace != null ? var.namespace : kubernetes_namespace.instance[0]
}

resource "kubernetes_namespace" "instance" {
  count = var.namespace == null ? 1 : 0
  metadata {
    name = local.instance
  }
}
