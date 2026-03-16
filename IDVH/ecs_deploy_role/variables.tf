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

variable "enabled" {
  type        = bool
  description = "(Optional) Dynamic override for deploy role creation. If null, enabled from IDVH tier YAML is used."
  default     = null
}

variable "service_name" {
  type        = string
  description = "(Required) Service name used as IAM role and policy prefix"
}

variable "github_repository" {
  type        = string
  description = "(Optional) GitHub repository in org/repo format"
  default     = null
}

variable "ecr_actions" {
  type        = list(string)
  description = "(Optional) Dynamic override for ECR deployment IAM actions. If null, values from IDVH tier YAML are used."
  default     = null
}

variable "ecs_actions" {
  type        = list(string)
  description = "(Optional) Dynamic override for ECS deployment IAM actions. If null, values from IDVH tier YAML are used."
  default     = null
}

variable "pass_role_arns" {
  type        = list(string)
  description = "(Required) IAM role ARNs allowed in iam:PassRole"
}

variable "role_description" {
  type        = string
  description = "(Optional) Dynamic override for the IAM role description. If null, the value from IDVH tier YAML is used."
  default     = null
}

variable "policy_description" {
  type        = string
  description = "(Optional) Dynamic override for the IAM policy description. If null, the value from IDVH tier YAML is used."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to IAM resources"
  default     = {}
}
