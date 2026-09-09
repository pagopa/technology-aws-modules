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

variable "repository_name_prefix" {
  type        = string
  description = "(Required) Prefix used to derive ECR repository names when no override is provided"
}

variable "repositories" {
  type = map(object({
    number_of_images_to_keep        = number
    repository_image_tag_mutability = string
  }))
  description = "(Optional) Dynamic ECR repositories override keyed by logical name. If null, repositories from IDVH tier YAML is used."
  default     = null
}

variable "repository_name_overrides" {
  type        = map(string)
  description = "(Optional) Explicit repository names keyed by logical repository key"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
