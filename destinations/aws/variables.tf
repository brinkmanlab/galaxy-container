locals {
  cluster_name = var.cluster_name
}

variable "cluster_name" {
  type = string
  default = "galaxy-cluster"
  description = "Name to assign to EKS cluster"
}