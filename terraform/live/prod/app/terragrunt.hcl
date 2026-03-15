include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${include.root.locals.terraform_root}//layers/app"
}

inputs = {
  environment_name          = "prod-retail-store"
  state_env                 = "prod"
  istio_enabled             = false
  opentelemetry_enabled     = false
  container_image_overrides = {}
  argocd_github_token       = ""
}
