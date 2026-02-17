variable "product_name" {
  type        = string
  description = "(Required) Product name used to identify the catalog to be used"

  validation {
    condition     = length(var.product_name) <= 12
    error_message = "Max length is 12 chars."
  }
}

variable "env" {
  type        = string
  description = "(Required) Environment for which the resource will be created"
}

variable "idvh_resource_tier" {
  type        = string
  description = "(Required) The IDVH resource tier key to be created"
}

variable "vpc_id" {
  type        = string
  description = "(Required) VPC identifier used by ECS services and NLB"
}

variable "private_subnets" {
  type        = list(string)
  description = "(Required) Private subnet IDs used by ECS services and NLB"
}

variable "vpc_cidr_block" {
  type        = string
  description = "(Required) CIDR block of the target VPC"
}

variable "service_core_image_version" {
  type        = string
  description = "(Required) Container image tag/version for service_core container"
}

variable "service_internal_idp_image_version" {
  type        = string
  description = "(Optional) Container image tag/version for service_internal_idp container. Required only when internal IDP is enabled."
  default     = null
}

variable "service_core_environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "(Optional) Additional environment variables appended to service_core tier defaults"
  default     = []
}

variable "service_internal_idp_environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "(Optional) Additional environment variables appended to service_internal_idp tier defaults"
  default     = []
}

variable "service_core_task_policy_json" {
  type        = string
  description = "(Optional) IAM policy JSON attached to the ECS core task role"
  default     = null
}

variable "service_internal_idp_task_policy_json" {
  type        = string
  description = "(Optional) IAM policy JSON attached to the ECS internal IDP task role"
  default     = null
}

variable "event_mode" {
  type        = bool
  description = "(Optional) Dynamic event-mode override. If null, event_mode from IDVH tier YAML is used."
  default     = null
}

variable "internal_idp_enabled" {
  type        = bool
  description = "(Optional) Dynamic internal-idp toggle override. If null, the YAML tier value is used."
  default     = null
}

variable "ecs_cluster_name" {
  type        = string
  description = "(Optional) Dynamic ECS cluster name override"
  default     = null
}

variable "nlb_name" {
  type        = string
  description = "(Optional) Dynamic NLB name override"
  default     = null
}

variable "github_repository" {
  type        = string
  description = "(Optional) GitHub repository in format org/repo. Used only when deploy_role.enabled is true in the selected tier."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
