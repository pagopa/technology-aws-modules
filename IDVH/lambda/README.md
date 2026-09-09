# IDVH Lambda

Wrapper module for AWS Lambda that loads dynamic configuration from the IDVH YAML catalog using:
- `product_name`
- `env`
- `idvh_resource_tier`

IDVH rule: structural parameters (for example `runtime`, `handler`, `architectures`, `timeout`, `publish`, and log retention) are defined by the selected YAML tier.
This module does not create the code bucket; you can pass an existing bucket name/ARN for output exposure.

This module uses:
- the raw Lambda module from `terraform-aws-modules` (pinned by commit hash)

If `lambda_policy_json` is built from values that are unknown during plan, set `attach_lambda_policy_json = true` explicitly. This avoids plan-time failures caused by the upstream module using the attach toggle in a `count` expression.

## Available tiers

The full catalog is in [LIBRARY.md](./LIBRARY.md).

## Example: tier with managed code bucket

```hcl
module "lambda_standard" {
  source = "git::https://github.com/your-org/your-terraform-modules.git//IDVH/lambda?ref=main"

  product_name       = "example"
  env                = "dev"
  idvh_resource_tier = "standard"

  name         = "example-dev-lambda"
  package_path = "./artifacts/lambda.zip"

  tags = {
    Project = "example"
    Env     = "dev"
  }
}
```

## Example: tier with external code bucket

```hcl
module "lambda_external_code_bucket" {
  source = "git::https://github.com/your-org/your-terraform-modules.git//IDVH/lambda?ref=main"

  product_name       = "example"
  env                = "dev"
  idvh_resource_tier = "standard_external_code_bucket"

  name         = "example-dev-lambda"
  package_path = "./artifacts/lambda.zip"

  existing_code_bucket_name = "example-dev-code-bucket"
  existing_code_bucket_arn  = "arn:aws:s3:::example-dev-code-bucket"

  tags = {
    Project = "example"
    Env     = "dev"
  }
}
```

## Example: computed IAM policy JSON

```hcl
data "aws_iam_policy_document" "lambda_extra" {
  statement {
    effect = "Allow"

    actions = [
      "xray:GetSamplingStatisticSummaries",
    ]

    resources = ["*"]
  }
}

module "lambda_with_policy" {
  source = "git::https://github.com/your-org/your-terraform-modules.git//IDVH/lambda?ref=main"

  product_name       = "example"
  env                = "dev"
  idvh_resource_tier = "standard"

  name         = "example-dev-lambda"
  package_path = "./artifacts/lambda.zip"

  attach_lambda_policy_json = true
  lambda_policy_json        = data.aws_iam_policy_document.lambda_extra.json
}
```

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
| <a name="module_lambda_raw"></a> [lambda\_raw](#module\_lambda\_raw) | git::https://github.com/terraform-aws-modules/terraform-aws-lambda.git | 55abacb6bfa49b3be9936c0947a913489aff0050 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | (Required) Environment for which the resource will be created | `string` | n/a | yes |
| <a name="input_idvh_resource_tier"></a> [idvh\_resource\_tier](#input\_idvh\_resource\_tier) | (Required) The IDVH resource tier key to be created | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Lambda function name | `string` | n/a | yes |
| <a name="input_package_path"></a> [package\_path](#input\_package\_path) | (Required) Local path to lambda zip package | `string` | n/a | yes |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | (Required) Product name used to identify the catalog to be used | `string` | n/a | yes |
| <a name="input_attach_lambda_policy_json"></a> [attach\_lambda\_policy\_json](#input\_attach\_lambda\_policy\_json) | (Optional) Explicit toggle for attaching lambda\_policy\_json. Set this to true when lambda\_policy\_json is computed from values that are unknown during plan. | `bool` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) Lambda description | `string` | `null` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | (Optional) Lambda environment variables | `map(string)` | `{}` | no |
| <a name="input_lambda_policy_json"></a> [lambda\_policy\_json](#input\_lambda\_policy\_json) | (Optional) IAM policy JSON attached to lambda execution role | `string` | `null` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | (Optional) Dynamic memory size override. Runtime and similar settings are controlled by IDVH tier YAML. | `number` | `null` | no |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | (Optional) Number of reserved concurrent executions for the Lambda function | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | (Optional) VPC security group ids for lambda. Must be set together with vpc\_subnet\_ids | `list(string)` | `[]` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | (Optional) VPC subnet ids for lambda. If empty, lambda is deployed outside VPC | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_lambda_deploy_policy_arn"></a> [github\_lambda\_deploy\_policy\_arn](#output\_github\_lambda\_deploy\_policy\_arn) | n/a |
| <a name="output_github_lambda_deploy_role_arn"></a> [github\_lambda\_deploy\_role\_arn](#output\_github\_lambda\_deploy\_role\_arn) | n/a |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | n/a |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | n/a |
| <a name="output_lambda_log_group_name"></a> [lambda\_log\_group\_name](#output\_lambda\_log\_group\_name) | n/a |
<!-- END_TF_DOCS -->