include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/terraform//layers/ops"
}

inputs = {
  environment_name      = "stage-retail-store"
  state_env             = "stage"
  opentelemetry_enabled = true
  istio_enabled         = false
}
