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

variable "bootstrap_state_env" {
  description = "State namespace used for the shared bootstrap state"
  type        = string
  default     = "stage"
}

variable "opentelemetry_enabled" {
  description = "Boolean value that enables OpenTelemetry."
  type        = bool
  default     = false
}

variable "istio_enabled" {
  description = "Boolean value that enables istio."
  type        = bool
  default     = false
}
