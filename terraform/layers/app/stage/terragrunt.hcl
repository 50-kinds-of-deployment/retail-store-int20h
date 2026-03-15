include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment_name          = "stage-retail-store"
  state_env                 = "stage"
  istio_enabled             = false
  opentelemetry_enabled     = false
  container_image_overrides = {}
  argocd_github_token       = ""
}
