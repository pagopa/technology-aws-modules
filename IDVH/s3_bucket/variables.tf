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
  description = "(Required) Base S3 bucket name provided by the module consumer"
}

variable "force_destroy" {
  type        = bool
  description = "(Optional) Override force_destroy configured by IDVH catalog"
  default     = null
}

variable "kms_key_arn" {
  type        = string
  description = "(Optional) KMS key ARN used for bucket SSE. If null, SSE algorithm from catalog is used"
  default     = null
}

variable "lifecycle_rule" {
  type        = list(any)
  description = "(Optional) Override lifecycle rules configured by IDVH catalog"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
