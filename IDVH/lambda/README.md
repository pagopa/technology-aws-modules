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

Currently available tiers for `onemail`:

| Environment | Tier | Runtime | Memory | Timeout | Code bucket |
|:-----------:|:----:|:-------:|:------:|:-------:|:-----------:|
| `dev` | `standard` | `provided.al2023` | `512` | `30` | created by module |
| `dev` | `standard_external_code_bucket` | `provided.al2023` | `512` | `30` | external bucket required |
| `uat` | `standard` | `provided.al2023` | `512` | `30` | created by module |
| `uat` | `standard_external_code_bucket` | `provided.al2023` | `512` | `30` | external bucket required |
| `prod` | `standard` | `provided.al2023` | `1024` | `60` | created by module |
| `prod` | `standard_external_code_bucket` | `provided.al2023` | `1024` | `60` | external bucket required |

## Examples for each available tier

### `dev` + `standard`

```hcl
module "onemail_lambda_dev_standard" {
  source = "./IDVH/lambda"

  product_name       = "onemail"
  env                = "dev"
  idvh_resource_tier = "standard"

  name         = "onemail-dev-lambda"
  package_path = "./artifacts/lambda.zip"

  tags = {
    Project = "onemail"
    Env     = "dev"
  }
}
```

### `dev` + `standard_external_code_bucket`

```hcl
module "onemail_lambda_dev_external_bucket" {
  source = "./IDVH/lambda"

  product_name       = "onemail"
  env                = "dev"
  idvh_resource_tier = "standard_external_code_bucket"

  name         = "onemail-dev-lambda"
  package_path = "./artifacts/lambda.zip"

  existing_code_bucket_name = "onemail-dev-code-bucket"
  existing_code_bucket_arn  = "arn:aws:s3:::onemail-dev-code-bucket"

  tags = {
    Project = "onemail"
    Env     = "dev"
  }
}
```

### `uat` + `standard`

```hcl
module "onemail_lambda_uat_standard" {
  source = "./IDVH/lambda"

  product_name       = "onemail"
  env                = "uat"
  idvh_resource_tier = "standard"

  name         = "onemail-uat-lambda"
  package_path = "./artifacts/lambda.zip"

  tags = {
    Project = "onemail"
    Env     = "uat"
  }
}
```

### `uat` + `standard_external_code_bucket`

```hcl
module "onemail_lambda_uat_external_bucket" {
  source = "./IDVH/lambda"

  product_name       = "onemail"
  env                = "uat"
  idvh_resource_tier = "standard_external_code_bucket"

  name         = "onemail-uat-lambda"
  package_path = "./artifacts/lambda.zip"

  existing_code_bucket_name = "onemail-uat-code-bucket"
  existing_code_bucket_arn  = "arn:aws:s3:::onemail-uat-code-bucket"

  tags = {
    Project = "onemail"
    Env     = "uat"
  }
}
```

### `prod` + `standard`

```hcl
module "onemail_lambda_prod_standard" {
  source = "./IDVH/lambda"

  product_name       = "onemail"
  env                = "prod"
  idvh_resource_tier = "standard"

  name         = "onemail-prod-lambda"
  package_path = "./artifacts/lambda.zip"

  tags = {
    Project = "onemail"
    Env     = "prod"
  }
}
```

### `prod` + `standard_external_code_bucket`

```hcl
module "onemail_lambda_prod_external_bucket" {
  source = "./IDVH/lambda"

  product_name       = "onemail"
  env                = "prod"
  idvh_resource_tier = "standard_external_code_bucket"

  name         = "onemail-prod-lambda"
  package_path = "./artifacts/lambda.zip"

  existing_code_bucket_name = "onemail-prod-code-bucket"
  existing_code_bucket_arn  = "arn:aws:s3:::onemail-prod-code-bucket"

  tags = {
    Project = "onemail"
    Env     = "prod"
  }
}
```
