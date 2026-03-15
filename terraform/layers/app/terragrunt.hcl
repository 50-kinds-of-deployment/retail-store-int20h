terraform {
  source = "."
}

inputs = {
  environment_name         = "stage-retail-store"
  istio_enabled            = false
  opentelemetry_enabled    = false
  container_image_overrides = {}
  argocd_github_token      = ""
}
