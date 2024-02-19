
variable "location" {
  description = "The location/region where the resources will be created."
  type        = string
  default     = "Sweden Central"
}

variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "ado-serverless-agents"
}

variable "subscription_id" {
  description = "The subscription id."
  type        = string
}

variable "azp_token" {
  description = "The Azure DevOps Personal Access Token."
  type        = string
}

variable "organization_url" {
  description = "The Azure DevOps organization URL."
  type        = string
}

variable "azp_pool" {
  description = "The Azure DevOps pool name."
  type        = string
}
