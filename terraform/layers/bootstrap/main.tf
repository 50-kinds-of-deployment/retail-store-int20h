import {
  to = aws_s3_bucket.retail_store_bucket
  id = "retail-store-tf-state-eu-central-1"
}

resource "aws_s3_bucket" "retail_store_bucket" {
  bucket = "retail-store-tf-state-eu-central-1"

  tags = {
    "Environment" = "shared"
    "Name"        = "Terraform State Bucket"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "retail_store_bucket" {
  bucket = aws_s3_bucket.retail_store_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

module "tags" {
  source = "../../lib/tags"

  environment_name = var.environment_name
}
