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
  description = "(Required) DynamoDB attribute definitions used by primary and index keys"
}

variable "global_secondary_indexes" {
  type = list(object({
    name               = string
    hash_key           = string
    projection_type    = string
    range_key          = optional(string)
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  description = "(Optional) Global secondary indexes"
  default     = []
}

variable "local_secondary_indexes" {
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string))
  }))
  description = "(Optional) Local secondary indexes"
  default     = []
}

variable "billing_mode" {
  type        = string
  description = "(Optional) Billing mode. Allowed values: PAY_PER_REQUEST, PROVISIONED"
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  type        = number
  description = "(Optional) Read capacity units when billing_mode is PROVISIONED"
  default     = null
}

variable "write_capacity" {
  type        = number
  description = "(Optional) Write capacity units when billing_mode is PROVISIONED"
  default     = null
}

variable "ttl_attribute_name" {
  type        = string
  description = "(Optional) TTL attribute name"
  default     = null
}

variable "ttl_enabled" {
  type        = bool
  description = "(Optional) Enable TTL on ttl_attribute_name"
  default     = false
}

variable "point_in_time_recovery_enabled" {
  type        = bool
  description = "(Optional) Enable point-in-time recovery"
  default     = true
}

variable "stream_enabled" {
  type        = bool
  description = "(Optional) Enable DynamoDB streams"
  default     = false
}

variable "stream_view_type" {
  type        = string
  description = "(Optional) Stream view type when stream_enabled is true"
  default     = null
}

variable "replication_regions" {
  type = list(object({
    region_name = string
  }))
  description = "(Optional) Replication regions for global tables"
  default     = []
}

variable "deletion_protection_enabled" {
  type        = bool
  description = "(Optional) Enable deletion protection"
  default     = false
}

variable "create_kms_key" {
  type        = bool
  description = "(Optional) Create a dedicated KMS key for this table"
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

variable "server_side_encryption_enabled" {
  type        = bool
  description = "(Optional) Enable server-side encryption for the table"
  default     = true
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
