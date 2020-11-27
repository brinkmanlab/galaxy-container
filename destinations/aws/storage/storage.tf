# See https://blog.abyssale.com/shared-storage-volume-on-amazon/
# TODO Convert https://github.com/DrFaust92/terraform-kubernetes-ebs-csi-driver to EFS and also use for S3 CSI
resource "aws_efs_file_system" "user_data" {
  tags = {
    Name     = "${var.user_data_volume_name}${local.name_suffix}"
    Instance = var.instance
  }
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
}

resource "aws_efs_mount_target" "user_data" {
  count           = length(var.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.user_data.id
  security_groups = [aws_security_group.efs.id]
  subnet_id       = var.vpc.private_subnets[count.index]
}

resource "aws_security_group" "efs" {
  name_prefix = "efs${local.name_suffix}-"
  description = "EFS security group"
  vpc_id      = var.vpc.vpc_id
  ingress {
    description = "NFS"
    cidr_blocks = [var.vpc.vpc_cidr_block]
    protocol    = "TCP"
    from_port   = 2049
    to_port     = 2049
  }
}