resource "aws_db_instance" "galaxy_db" {
  identifier            = "${local.db_name}${local.name_suffix}"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  engine                = "postgres"    # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
  instance_class        = "db.t3.micro" # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
  name                  = local.db_conf.name
  username              = local.db_conf.user
  password              = local.db_conf.pass
  #parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids    = [var.eks.worker_security_group_id]
  db_subnet_group_name      = var.vpc.database_subnet_group
  publicly_accessible       = false
  skip_final_snapshot       = var.debug
  final_snapshot_identifier = "${local.db_conf.name}-${formatdate("YYYYMMDDhhmmss", timestamp())}"
}

## Register database in internal DNS
resource "kubernetes_service" "galaxy_db" {
  metadata {
    name      = local.db_conf.host
    namespace = local.namespace.metadata.0.name
  }
  spec {
    type          = "ExternalName"
    external_name = aws_db_instance.galaxy_db.address
  }
}