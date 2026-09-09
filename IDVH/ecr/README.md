# IDVH ecr

Reusable wrapper module for ECR repositories.

It creates one repository per logical key from `repositories`, deriving names with `repository_name_prefix` unless an explicit override is provided.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.26.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_idvh_loader"></a> [idvh\_loader](#module\_idvh\_loader) | ../01_idvh_loader | n/a |
| <a name="module_repository"></a> [repository](#module\_repository) | git::https://github.com/terraform-aws-modules/terraform-aws-ecr.git | 9f4b587846551110b0db199ea5599f016570fefe |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | (Required) Environment for which the resource will be created | `string` | n/a | yes |
| <a name="input_idvh_resource_tier"></a> [idvh\_resource\_tier](#input\_idvh\_resource\_tier) | (Required) The IDVH resource tier key to be created | `string` | n/a | yes |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | (Required) Product name used to identify the catalog to be used | `string` | n/a | yes |
| <a name="input_repository_name_prefix"></a> [repository\_name\_prefix](#input\_repository\_name\_prefix) | (Required) Prefix used to derive ECR repository names when no override is provided | `string` | n/a | yes |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | (Optional) Dynamic ECR repositories override keyed by logical name. If null, repositories from IDVH tier YAML is used. | <pre>map(object({<br/>    number_of_images_to_keep        = number<br/>    repository_image_tag_mutability = string<br/>  }))</pre> | `null` | no |
| <a name="input_repository_name_overrides"></a> [repository\_name\_overrides](#input\_repository\_name\_overrides) | (Optional) Explicit repository names keyed by logical repository key | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repository_names"></a> [repository\_names](#output\_repository\_names) | n/a |
| <a name="output_repository_urls"></a> [repository\_urls](#output\_repository\_urls) | n/a |
<!-- END_TF_DOCS -->