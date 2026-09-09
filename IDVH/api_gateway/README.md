# IDVH api_gateway

Wrapper module for API Gateway REST APIs that loads structural settings from IDVH YAML catalog using:
- `product_name`
- `env`
- `idvh_resource_tier`

IDVH rule: endpoint/stage/cache/method settings, usage plan and domain/authorizer defaults are defined by the selected YAML tier.

## IDVH resources available
[Here's](./LIBRARY.md) the list of `idvh_resource_tier` available for this module.

## Example

```hcl
module "api_gateway" {
  source = "git::https://github.com/your-org/your-terraform-modules.git//IDVH/api_gateway?ref=main"

  product_name       = "example"
  env                = "dev"
  idvh_resource_tier = "standard"

  name = "example-dev-rest-api"
  body = file("./openapi.json")
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.32.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_idvh_loader"></a> [idvh\_loader](#module\_idvh\_loader) | ../01_idvh_loader | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account) | resource |
| [aws_api_gateway_api_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_api_key) | resource |
| [aws_api_gateway_authorizer.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_authorizer) | resource |
| [aws_api_gateway_deployment.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_domain_name.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_domain_name) | resource |
| [aws_api_gateway_method_settings.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_rest_api.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_api_gateway_usage_plan.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan) | resource |
| [aws_api_gateway_usage_plan_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan_key) | resource |
| [aws_apigatewayv2_api_mapping.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api_mapping) | resource |
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.apigw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_body"></a> [body](#input\_body) | (Required) OpenAPI/Swagger specification body | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | (Required) Environment for which the resource will be created | `string` | n/a | yes |
| <a name="input_idvh_resource_tier"></a> [idvh\_resource\_tier](#input\_idvh\_resource\_tier) | (Required) The IDVH resource tier key to be created | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) REST API name | `string` | n/a | yes |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | (Required) Product name used to identify the catalog to be used | `string` | n/a | yes |
| <a name="input_api_authorizer_name"></a> [api\_authorizer\_name](#input\_api\_authorizer\_name) | (Optional) Dynamic Cognito authorizer name override | `string` | `null` | no |
| <a name="input_api_authorizer_user_pool_arn"></a> [api\_authorizer\_user\_pool\_arn](#input\_api\_authorizer\_user\_pool\_arn) | (Optional) Dynamic Cognito user pool ARN override | `string` | `null` | no |
| <a name="input_api_mapping_key"></a> [api\_mapping\_key](#input\_api\_mapping\_key) | (Optional) Dynamic API mapping key override | `string` | `null` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | (Optional) Dynamic certificate ARN override for custom domain | `string` | `null` | no |
| <a name="input_custom_domain_name"></a> [custom\_domain\_name](#input\_custom\_domain\_name) | (Optional) Dynamic custom domain override | `string` | `null` | no |
| <a name="input_endpoint_api_types"></a> [endpoint\_api\_types](#input\_endpoint\_api\_types) | (Optional) Dynamic API types override for endpoint configuration | `list(string)` | `null` | no |
| <a name="input_endpoint_vpc_endpoint_ids"></a> [endpoint\_vpc\_endpoint\_ids](#input\_endpoint\_vpc\_endpoint\_ids) | (Optional) Dynamic VPC endpoint IDs override for PRIVATE endpoint configurations | `list(string)` | `null` | no |
| <a name="input_plan_api_key_name"></a> [plan\_api\_key\_name](#input\_plan\_api\_key\_name) | (Optional) Dynamic usage-plan API key name override | `string` | `null` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | n/a | `string` | `null` | no |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | (Optional) Dynamic stage name override. If null, stage\_name from IDVH tier YAML is used. | `string` | `null` | no |
| <a name="input_stage_variables"></a> [stage\_variables](#input\_stage\_variables) | (Optional) Dynamic stage variables override for the deployed stage | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | n/a |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | n/a |
| <a name="output_regional_domain_name"></a> [regional\_domain\_name](#output\_regional\_domain\_name) | n/a |
| <a name="output_regional_zone_id"></a> [regional\_zone\_id](#output\_regional\_zone\_id) | n/a |
| <a name="output_rest_api_arn"></a> [rest\_api\_arn](#output\_rest\_api\_arn) | n/a |
| <a name="output_rest_api_execution_arn"></a> [rest\_api\_execution\_arn](#output\_rest\_api\_execution\_arn) | n/a |
| <a name="output_rest_api_id"></a> [rest\_api\_id](#output\_rest\_api\_id) | n/a |
| <a name="output_rest_api_invoke_url"></a> [rest\_api\_invoke\_url](#output\_rest\_api\_invoke\_url) | n/a |
| <a name="output_rest_api_name"></a> [rest\_api\_name](#output\_rest\_api\_name) | n/a |
| <a name="output_rest_api_stage_name"></a> [rest\_api\_stage\_name](#output\_rest\_api\_stage\_name) | n/a |
<!-- END_TF_DOCS -->