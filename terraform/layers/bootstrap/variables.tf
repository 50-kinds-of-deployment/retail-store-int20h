variable "environment_name" {
  type        = string
  description = "The name of the environment (e.g. retail-store)"
  default     = "stage-retail-store"
}

variable "gh_oidc_sub" {
  type        = string
  description = "The GitHub subject for the OIDC role"
  default     = "repo:50-kinds-of-deployment/retail-store-int20h:*"
}

variable "oidc_gha_role_path" {
  type        = string
  description = "Path to the OIDC Assume Role Policy JSON"
  default     = "policies/assume_role_policy.json.tpl"
}

variable "oidc_gha_role_policy_path" {
  type        = string
  description = "Path to the Github Actions Policy JSON"
  default     = "policies/github_actions_policy.json"
}
