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
