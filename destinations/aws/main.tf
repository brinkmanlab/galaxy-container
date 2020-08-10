module "galaxy-k8s" {
  source = "../k8s"
  depends = module.eks.cluster_id
  instance = var.instance
  nfs_server = aws_efs_file_system.user_data.dns_name
  db_conf = local.db_conf
}