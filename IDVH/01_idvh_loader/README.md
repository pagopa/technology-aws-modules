# 01_idvh_loader

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | (Required) Environment used to identify the catalog to be used | `string` | n/a | yes |
| <a name="input_idvh_resource_tier"></a> [idvh\_resource\_tier](#input\_idvh\_resource\_tier) | (Required) The IDVH resource tier name chosen for the resource to be created. | `string` | n/a | yes |
| <a name="input_idvh_resource_type"></a> [idvh\_resource\_type](#input\_idvh\_resource\_type) | (Required) The IDVH resource category to be created. | `string` | n/a | yes |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | (Required) Product name used to identify the catalog to be used | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_idvh_resource_configuration"></a> [idvh\_resource\_configuration](#output\_idvh\_resource\_configuration) | n/a |
| <a name="output_idvh_resource_tier"></a> [idvh\_resource\_tier](#output\_idvh\_resource\_tier) | n/a |
| <a name="output_idvh_resource_type"></a> [idvh\_resource\_type](#output\_idvh\_resource\_type) | n/a |
| <a name="output_idvh_tiers_configurations"></a> [idvh\_tiers\_configurations](#output\_idvh\_tiers\_configurations) | n/a |
<!-- END_TF_DOCS -->
