# IDVH Lambda

Wrapper module for AWS Lambda that loads dynamic configuration from the IDVH YAML catalog using:
- `product_name`
- `env`
- `idvh_resource_tier`

IDVH rule: structural parameters (for example `runtime`, `handler`, `architectures`, `timeout`, `publish`, log retention, code bucket behavior) are defined by the selected YAML tier.

This module uses:
- the raw Lambda module from `terraform-aws-modules` (pinned by commit hash)
- the IDVH `s3_bucket` module (`source = "../s3_bucket"`) when the tier requires code bucket creation

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
