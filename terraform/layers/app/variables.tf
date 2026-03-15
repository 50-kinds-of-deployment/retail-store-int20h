variable "environment_name" {
  description = "Name of the environment"
  type        = string
  default     = "stage-retail-store"
}

variable "state_env" {
  description = "State namespace used in remote state keys (e.g. stage, prod)"
  type        = string
  default     = "stage"
}

variable "istio_enabled" {
  description = "Boolean value that enables istio."
  type        = bool
  default     = false
}

variable "opentelemetry_enabled" {
  description = "Boolean value that enables OpenTelemetry."
  type        = bool
  default     = false
}

variable "container_image_overrides" {
  type = object({
    default_repository = optional(string)
    default_tag        = optional(string)

    ui       = optional(string)
    catalog  = optional(string)
    cart     = optional(string)
    checkout = optional(string)
    orders   = optional(string)
  })
  default     = {}
  description = "Object that encapsulates any overrides to default values"
}

variable "argocd_github_token" {
  description = "GitHub token for ArgoCD repository access"
  type        = string
  sensitive   = true
  default     = ""
}
