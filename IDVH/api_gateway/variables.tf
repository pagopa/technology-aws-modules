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
  description = "(Required) API Gateway HTTP API name"
}

variable "description" {
  type        = string
  description = "(Optional) HTTP API description"
  default     = null
}

variable "stage_name" {
  type        = string
  description = "(Optional) Dynamic stage name override. If null, stage_name from IDVH tier YAML is used."
  default     = null
}

variable "access_log_format" {
  type        = string
  description = "(Optional) Dynamic access log format override. If null, format from IDVH tier YAML is used."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
