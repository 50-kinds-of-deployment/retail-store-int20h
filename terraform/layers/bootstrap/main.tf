resource "aws_s3_bucket" "retail_store_bucket" {
  bucket = "retail-store-bucket-terraform-s3"

  object_lock_enabled = true
}

module "tags" {
  source = "../../../lib/tags"

  environment_name = var.environment_name
}
