data "terraform_remote_state" "ops" {
  backend = "local"

  config = {
    path = "../ops/terraform.tfstate"
  }
}

data "terraform_remote_state" "bootstrap" {
  backend = "local"

  config = {
    path = "../bootstrap/terraform.tfstate"
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
  depends_on = [helm_release.ui]

  metadata {
    name      = "ui"
    namespace = "ui"
  }
}
