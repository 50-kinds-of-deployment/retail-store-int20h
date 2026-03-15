locals {
  aws_region     = "eu-central-1"
  state_bucket   = "retail-store-tf-state-eu-central-1"
  terraform_root = abspath("${get_terragrunt_dir()}/../..")
  layer_name     = basename(get_terragrunt_dir())
}

terraform {
  source = "${local.terraform_root}//layers/${local.layer_name}"
}

remote_state {
  backend = "s3"
  config = {
    bucket  = local.state_bucket
    key     = "${path_relative_to_include()}/${local.layer_name}/terraform.tfstate"
    region  = local.aws_region
    encrypt = true
  }
}
