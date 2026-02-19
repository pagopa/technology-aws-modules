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

variable "table_config" {
  type = object({
    table_name                  = string
    hash_key                    = string
    range_key                   = optional(string)
    attributes                  = list(object({ name = string, type = string }))
    billing_mode                = optional(string, "PAY_PER_REQUEST")
    stream_enabled              = optional(bool, false)
    stream_view_type            = optional(string)
    ttl_enabled                 = optional(bool, false)
    ttl_attribute_name          = optional(string, "")
    deletion_protection_enabled = optional(bool, false)
    global_secondary_indexes    = optional(any, [])
    local_secondary_indexes     = optional(any, [])
    replica_regions = optional(list(object({
      region_name = string
      kms_key_arn = optional(string)
    })), [])
  })
  description = "(Required) DynamoDB table configuration passed to upstream module"
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

variable "enable_point_in_time_recovery" {
  type        = bool
  description = "(Optional) Enable point-in-time recovery. If null and idvh_resource_tier is set, the IDVH tier value is used."
  default     = null
}

# variable "policy" {
#   type        = string
#   description = "(Optional) JSON policy for the KMS key when create_kms_key is true"
#   default     = null
# }

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
