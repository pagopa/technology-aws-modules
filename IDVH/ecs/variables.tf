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

variable "service_name" {
  type        = string
  description = "(Required) ECS service name"
}

variable "container_name" {
  type        = string
  description = "(Required) Main container name"
}

variable "image" {
  type        = string
  description = "(Required) Full container image URI including tag"
}

variable "cluster_arn" {
  type        = string
  description = "(Required) ECS cluster ARN hosting the service"
}

variable "private_subnets" {
  type        = list(string)
  description = "(Required) Private subnet IDs used by the ECS service"
}

variable "target_group_arn" {
  type        = string
  description = "(Required) NLB target group ARN attached to the ECS service"
}

variable "nlb_security_group_id" {
  type        = string
  description = "(Required) NLB security group ID used for ECS ingress rules"
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "(Optional) Additional environment variables appended to tier defaults"
  default     = []
}

variable "task_policy_json" {
  type        = string
  description = "(Optional) IAM policy JSON attached to the ECS task role"
  default     = null
}

variable "event_mode" {
  type        = bool
  description = "(Optional) Dynamic event-mode override. If null, event_mode from IDVH tier YAML is used."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
