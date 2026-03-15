terraform {
  source = "."
}

inputs = {
  environment_name      = "stage-retail-store"
  opentelemetry_enabled = true
  istio_enabled         = false
}
