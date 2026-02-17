variable "repository_name_prefix" {
  type        = string
  description = "(Required) Prefix used to derive ECR repository names when no override is provided"
}

variable "repositories" {
  type = map(object({
    number_of_images_to_keep        = number
    repository_image_tag_mutability = string
  }))
  description = "(Required) ECR repositories keyed by logical name"
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
