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

variable "table_name" {
  type        = string
  description = "(Required) DynamoDB table name"
}

variable "hash_key" {
  type        = string
  description = "(Required) Partition key attribute name"
}

variable "attributes" {
  type = list(object({
    name = string
    type = string
  }))
  description = "(Required) DynamoDB attribute definitions used by primary and index keys"
}

variable "create_kms_key" {
  type        = bool
  description = "(Optional) Create a dedicated KMS key for DynamoDB table encryption"
  default     = false
}

variable "kms_alias" {
  type        = string
  description = "(Optional) KMS alias used when create_kms_key is true"
  default     = null
}

variable "kms_description" {
  type        = string
  description = "(Optional) Description for the created KMS key"
  default     = "KMS key for DynamoDB table encryption."
}

variable "kms_enable_key_rotation" {
  type        = bool
  description = "(Optional) KMS rotation override. If null and create_kms_key is true, the IDVH tier value is used."
  default     = null
}

variable "kms_rotation_period_in_days" {
  type        = number
  description = "(Optional) KMS rotation period override. If null and create_kms_key is true, the IDVH tier value is used."
  default     = null
}

variable "server_side_encryption_kms_key_arn" {
  type        = string
  description = "(Optional) Existing KMS key ARN used for table encryption when create_kms_key is false"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
