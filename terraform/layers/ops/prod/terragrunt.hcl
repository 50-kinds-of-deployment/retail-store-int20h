include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/terraform//layers/ops"
}

generate "imports" {
  path      = "zz_imports.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    import {
      to = aws_eks_addon.ebs_csi
      id = "prod-retail-store:aws-ebs-csi-driver"
    }

    import {
      to = aws_eks_addon.metrics_server
      id = "prod-retail-store:metrics-server"
    }

    import {
      to = module.retail_app_eks.module.eks_cluster.kubernetes_config_map.aws_auth[0]
      id = "kube-system/aws-auth"
    }
  EOF
}

inputs = {
  environment_name      = "prod-retail-store"
  state_env             = "prod"
  bootstrap_state_env   = "stage"
  opentelemetry_enabled = true
  istio_enabled         = false
}
