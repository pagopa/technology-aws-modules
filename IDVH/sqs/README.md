# IDVH sqs

Wrapper module for AWS SQS that loads structural settings from IDVH YAML catalog using:
- `product_name`
- `env`
- `idvh_resource_tier`

IDVH rule: queue behavior (retention, delays, encryption defaults, DLQ policy) is defined by the selected YAML tier.

## IDVH resources available
[Here's](./LIBRARY.md) the list of `idvh_resource_tier` available for this module.

## Example

```hcl
module "sqs" {
  source = "git::https://github.com/your-org/your-terraform-modules.git//IDVH/sqs?ref=main"

  product_name       = "example"
  env                = "dev"
  idvh_resource_tier = "standard"

  name = "example-dev-events"

  tags = {
    Project = "example"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.32.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.63.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_idvh_loader"></a> [idvh\_loader](#module\_idvh\_loader) | ../01_idvh_loader | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_sqs_queue.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | (Required) Environment for which the resource will be created | `string` | n/a | yes |
| <a name="input_idvh_resource_tier"></a> [idvh\_resource\_tier](#input\_idvh\_resource\_tier) | (Required) The IDVH resource tier key to be created | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Base SQS queue name | `string` | n/a | yes |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | (Required) Product name used to identify the catalog to be used | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | (Optional) KMS key ID/ARN for queue encryption. If null, tier-managed SSE settings are used. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_visibility_timeout_seconds"></a> [visibility\_timeout\_seconds](#input\_visibility\_timeout\_seconds) | (Optional) Dynamic visibility timeout override. If null, the tier value is used. | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dead_letter_queue_arn"></a> [dead\_letter\_queue\_arn](#output\_dead\_letter\_queue\_arn) | n/a |
| <a name="output_dead_letter_queue_name"></a> [dead\_letter\_queue\_name](#output\_dead\_letter\_queue\_name) | n/a |
| <a name="output_dead_letter_queue_url"></a> [dead\_letter\_queue\_url](#output\_dead\_letter\_queue\_url) | n/a |
| <a name="output_queue_arn"></a> [queue\_arn](#output\_queue\_arn) | n/a |
| <a name="output_queue_name"></a> [queue\_name](#output\_queue\_name) | n/a |
| <a name="output_queue_url"></a> [queue\_url](#output\_queue\_url) | n/a |
<!-- END_TF_DOCS -->