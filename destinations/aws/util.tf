resource "helm_release" "dashboard" {
  name      = "dashboard-chart"
  chart     = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  namespace = local.k8s_service_account_namespace

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }
  depends_on = [module.eks.cluster_id]
}