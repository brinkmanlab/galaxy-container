locals {
  namespace      = var.namespace != null ? var.namespace : kubernetes_namespace.instance[0]
  nfs_server     = var.nfs_server != "" ? var.nfs_server : module.nfs_server[0].nfs_server
  lb_annotations = {
    "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" : "http"
    "service.beta.kubernetes.io/aws-load-balancer-connection-draining-enabled" : true
    "service.beta.kubernetes.io/aws-load-balancer-connection-draining-timeout" : 120
    "service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout" : 120
  }
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "kubernetes_namespace" "instance" {
  count = var.namespace == null ? 1 : 0
  metadata {
    name = local.instance
  }
}

module "nfs_server" {
  source                = "./storage"
  count                 = var.nfs_server == "" ? 1 : 0
  user_data_volume_name = local.user_data_volume_name
  instance              = local.instance
  vpc                   = var.vpc
}

module "k8s" {
  source                     = "../k8s"
  depends_on                 = [var.eks, kubernetes_service.galaxy_db, kubernetes_service.galaxy_mail]
  instance                   = var.instance
  nfs_server                 = local.nfs_server
  db_conf                    = local.db_conf
  galaxy_conf                = merge(local.galaxy_conf, local.smtp_conf)
  admin_users                = var.admin_users
  app_name                   = var.app_name
  config_dir                 = var.config_dir
  managed_config_dir         = var.managed_config_dir
  data_dir                   = var.data_dir
  db_data_volume_name        = var.db_data_volume_name
  db_name                    = var.db_name
  tusd_name                  = var.tusd_name
  celery_worker_name         = var.celery_worker_name
  celery_beat_name           = var.celery_beat_name
  galaxy_app_image           = var.galaxy_app_image
  galaxy_root_volume_name    = var.galaxy_root_volume_name
  galaxy_web_image           = var.galaxy_web_image
  db_image                   = local.db_image
  tusd_image                 = local.tusd_image
  image_tag                  = var.image_tag
  tusd_tag                   = var.tusd_tag
  mail_name                  = var.mail_name
  mail_port                  = var.mail_port
  root_dir                   = var.root_dir
  user_data_volume_name      = var.user_data_volume_name
  web_name                   = var.web_name
  worker_name                = var.worker_name
  email                      = var.email
  debug                      = var.debug
  app_port                   = var.app_port
  app_uid                    = var.app_uid
  app_gid                    = var.app_gid
  master_api_key             = local.master_api_key
  lb_annotations             = merge(local.lb_annotations, var.lb_annotations)
  tool_mappings              = var.tool_mappings
  namespace                  = local.namespace
  id_secret                  = local.id_secret
  extra_mounts               = var.extra_mounts
  extra_job_mounts           = var.extra_job_mounts
  plugins                    = var.plugins
  job_destinations           = var.job_destinations
  limits                     = var.limits
  visualizations             = var.visualizations
  web_max_replicas           = var.web_max_replicas
  app_max_replicas           = var.app_max_replicas
  worker_max_replicas        = var.worker_max_replicas
  tusd_max_replicas          = var.tusd_max_replicas
  celery_worker_max_replicas = var.celery_worker_max_replicas
  static_tool_data_tables    = var.static_tool_data_tables
  tool_containers            = var.tool_containers
}