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

variable "idh_resource_tier" {
  type        = string
  description = "(Required) The IDVH resource tier key to be created"
}

variable "name" {
  type        = string
  description = "(Required) Lambda function name"
}

variable "package_path" {
  type        = string
  description = "(Required) Local path to lambda zip package"
}

variable "description" {
  type        = string
  description = "(Optional) Lambda description"
  default     = null
}

variable "memory_size" {
  type        = number
  description = "(Optional) Dynamic memory size override. Runtime and similar settings are controlled by IDVH tier YAML."
  default     = null
}

variable "environment_variables" {
  type        = map(string)
  description = "(Optional) Lambda environment variables"
  default     = {}
}

variable "lambda_policy_json" {
  type        = string
  description = "(Optional) IAM policy JSON attached to lambda execution role"
  default     = null
}

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "(Optional) VPC subnet ids for lambda. If empty, lambda is deployed outside VPC"
  default     = []
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "(Optional) VPC security group ids for lambda. Must be set together with vpc_subnet_ids"
  default     = []
}

variable "existing_code_bucket_name" {
  type        = string
  description = "(Optional) Existing bucket name used by tiers where code_bucket.enabled is false"
  default     = null
}

variable "existing_code_bucket_arn" {
  type        = string
  description = "(Optional) Existing bucket ARN used by tiers where code_bucket.enabled is false"
  default     = null
}

variable "github_repository" {
  type        = string
  description = "(Optional) GitHub repository in format org/repo, required to create deploy role"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
