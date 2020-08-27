data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "galaxy-k8s" {
  source                  = "../k8s"
  depends_on              = [var.eks, kubernetes_service.galaxy_db, kubernetes_service.galaxy_mail, aws_efs_mount_target.user_data]
  instance                = var.instance
  nfs_server              = aws_efs_file_system.user_data.dns_name
  db_conf                 = local.db_conf
  galaxy_conf             = merge(local.galaxy_conf, local.smtp_conf, local.galaxy_db_conf)
  admin_users             = var.admin_users
  app_name                = var.app_name
  config_dir              = var.config_dir
  data_dir                = var.data_dir
  db_data_volume_name     = var.db_data_volume_name
  db_name                 = var.db_name
  galaxy_app_image        = var.galaxy_app_image
  galaxy_root_volume_name = var.galaxy_root_volume_name
  galaxy_web_image        = var.galaxy_web_image
  image_tag               = var.image_tag
  mail_name               = var.mail_name
  mail_port               = var.mail_port
  root_dir                = var.root_dir
  user_data_volume_name   = var.user_data_volume_name
  web_name                = var.web_name
  worker_name             = var.worker_name
  email                   = var.email
  debug                   = var.debug
  uwsgi_port              = var.uwsgi_port
  master_api_key          = local.master_api_key
}