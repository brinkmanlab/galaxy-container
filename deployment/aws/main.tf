provider "aws" {
  region = var.region
}

module "cloud" {
  source             = "github.com/brinkmanlab/cloud_recipes.git//aws" #?ref=v0.1.2"
  cluster_name       = var.instance
  autoscaler_version = "1.17.3"
  debug              = var.debug
}

data "aws_eks_cluster" "cluster" {
  name = module.cloud.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.cloud.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "galaxy" {
  source   = "../../destinations/aws"
  instance = var.instance
  galaxy_conf = {
    email_from     = var.email
    error_email_to = var.email
    require_login  = true
    #allow_user_creation = false
    #cleanup_job = "never"
    slow_query_log_threshold = 500
  }
  image_tag           = "latest"
  admin_users         = [var.email]
  email               = var.email
  debug               = var.debug
  eks                 = module.cloud.eks
  vpc                 = module.cloud.vpc
  worker_max_replicas = 3
}

module "admin_user" {
  source         = "../../modules/bootstrap_admin"
  email          = var.email
  galaxy_url     = "http://${module.galaxy.endpoint}"
  master_api_key = module.galaxy.master_api_key
  username       = "admin"
}

provider "galaxy" {
  host   = "http://${module.galaxy.endpoint}"
  apikey = module.admin_user.api_key
}