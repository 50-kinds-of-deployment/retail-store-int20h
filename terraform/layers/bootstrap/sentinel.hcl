mock "tfplan/v2" {
  data = {
    tfplan = "tfplan.json"
  }
}

policy "bootstrap" {
  source            = "./bootstrap.sentinel"
  enforcement_level = "hard-mandatory"
}
