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
  description = "(Required) Base SQS queue name"
}

variable "visibility_timeout_seconds" {
  type        = number
  description = "(Optional) Dynamic visibility timeout override. If null, the tier value is used."
  default     = null
}

variable "kms_key_id" {
  type        = string
  description = "(Optional) KMS key ID/ARN for queue encryption. If null, tier-managed SSE settings are used."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
