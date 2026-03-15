include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/terraform//layers/app"
}

inputs = {
  environment_name          = "prod-retail-store"
  state_env                 = "prod"
  bootstrap_state_env       = "stage"
  resolve_ui_service_url    = false
  istio_enabled             = false
  opentelemetry_enabled     = false
  container_image_overrides = {}
  argocd_github_token       = ""
}
