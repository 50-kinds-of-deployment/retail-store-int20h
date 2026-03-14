mock "tfplan/v2" {
  module {
    source = "tfplan.json"
    format = "json"
  }
}

policy "bootstrap" {
  source            = "./bootstrap.sentinel"
  enforcement_level = "hard-mandatory"
}
