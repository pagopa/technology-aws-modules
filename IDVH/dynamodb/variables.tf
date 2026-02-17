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

variable "name" {
  type        = string
  description = "(Required) DynamoDB table name"
}

variable "hash_key" {
  type        = string
  description = "(Required) Partition key attribute name"
}

variable "range_key" {
  type        = string
  description = "(Optional) Sort key attribute name"
  default     = null
}

variable "attributes" {
  type = list(object({
    name = string
    type = string
  }))
  description = "(Required) DynamoDB attribute definitions used by hash_key/range_key"
}

variable "read_capacity" {
  type        = number
  description = "(Optional) Read capacity units, required only when tier billing_mode is PROVISIONED"
  default     = null
}

variable "write_capacity" {
  type        = number
  description = "(Optional) Write capacity units, required only when tier billing_mode is PROVISIONED"
  default     = null
}

variable "kms_key_arn" {
  type        = string
  description = "(Optional) KMS key ARN for table encryption"
  default     = null
}

variable "point_in_time_recovery_enabled" {
  type        = bool
  description = "(Optional) Dynamic override for point-in-time recovery"
  default     = null
}

variable "deletion_protection_enabled" {
  type        = bool
  description = "(Optional) Dynamic override for deletion protection"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
