resource "random_string" "object_store_access_key" {
  length = 16
}

resource "random_password" "object_store_secret_key" {
  length = 16
}

provider "aws" {
  version = "~> 2.0"
  alias = "object_store"
  access_key = local.object_store_access_key
  secret_key = local.object_store_secret_key
  endpoints {
    s3 = "object_store"
  }
}

resource "aws_s3_bucket" "user_data" {
  provider = aws.object_store
  bucket_prefix = "user_data"
}