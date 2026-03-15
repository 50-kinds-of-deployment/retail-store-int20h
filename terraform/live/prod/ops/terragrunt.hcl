include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${include.root.locals.terraform_root}//layers/ops"
}

inputs = {
  environment_name      = "prod-retail-store"
  state_env             = "prod"
  opentelemetry_enabled = true
  istio_enabled         = false
}
