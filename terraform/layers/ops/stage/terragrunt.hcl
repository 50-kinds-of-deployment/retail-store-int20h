include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment_name      = "stage-retail-store"
  state_env             = "stage"
  opentelemetry_enabled = true
  istio_enabled         = false
}
