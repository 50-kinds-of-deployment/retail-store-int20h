data "terraform_remote_state" "ops" {
  backend = "s3"

  config = {
    bucket = "retail-store-tf-state-eu-central-1"
    key    = "${var.state_env}/ops/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "bootstrap" {
  backend = "s3"

  config = {
    bucket = "retail-store-tf-state-eu-central-1"
    key    = "${var.state_env}/bootstrap/terraform.tfstate"
    region = "eu-central-1"
  }
}

locals {
  ops_outputs = data.terraform_remote_state.ops.outputs
  tags        = data.terraform_remote_state.bootstrap.outputs.tags
}

data "aws_eks_cluster_auth" "this" {
  name = local.ops_outputs.eks_cluster_id

  depends_on = [
    null_resource.cluster_blocker
  ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.ops_outputs.eks_cluster_id
}

data "kubernetes_service" "ui_service" {
  metadata {
    name      = "ui"
    namespace = "ui"
  }
}
