include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${include.root.locals.terraform_root}//layers/bootstrap"
}

inputs = {
  environment_name          = "stage-retail-store"
  gh_oidc_sub               = "repo:50-kinds-of-deployment/retail-store-int20h:*"
  oidc_gha_role_path        = "policies/assume_role_policy.json.tpl"
  oidc_gha_role_policy_path = "policies/github_actions_policy.json"
}
