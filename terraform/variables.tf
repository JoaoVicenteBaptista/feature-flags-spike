variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "ffpoc"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "feature_a_env_value" {
  description = "FeatureA value set via environment variable fallback"
  type        = bool
  default     = true
}

variable "feature_b_env_value" {
  description = "FeatureB value set via environment variable fallback"
  type        = bool
  default     = false
}

variable "feature_a_appconfig_value" {
  description = "FeatureA value set in Azure App Configuration"
  type        = bool
  default     = false
}

variable "feature_b_appconfig_value" {
  description = "FeatureB value set in Azure App Configuration"
  type        = bool
  default     = false
}
