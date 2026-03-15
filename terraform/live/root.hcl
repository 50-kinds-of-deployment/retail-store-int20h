locals {
  aws_region   = "eu-central-1"
  state_bucket = "retail-store-tf-state-eu-central-1"
}

remote_state {
  backend = "s3"
  config = {
    bucket  = local.state_bucket
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = local.aws_region
    encrypt = true
  }
}
