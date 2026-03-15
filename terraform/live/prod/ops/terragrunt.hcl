include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../layers/ops"
}

inputs = {
  environment_name      = "prod-retail-store"
  state_env             = "prod"
  opentelemetry_enabled = true
  istio_enabled         = false
}
