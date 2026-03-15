locals {
  aws_region   = "eu-central-1"
  state_bucket = "retail-store-tf-state-eu-central-1"
  layer_name   = basename(dirname(find_in_parent_folders("root.hcl")))
}

remote_state {
  backend = "s3"
  config = {
    bucket  = local.state_bucket
    key     = "stage/${local.layer_name}/terraform.tfstate"
    region  = local.aws_region
    encrypt = true
  }
}
