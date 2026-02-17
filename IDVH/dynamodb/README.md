# IDVH dynamodb

Atomic wrapper module for a single DynamoDB table that loads IDVH tier defaults using:
- `product_name`
- `env`
- `idvh_resource_tier`

Table schema and table behavior are passed from outside via module inputs.

IDVH rule: `dynamodb.yml` keeps only KMS defaults (`kms_ssm_enable_rotation`, `kms_rotation_period_in_days`).

## IDVH resources available
[Here's](./LIBRARY.md) the list of `idvh_resource_tier` available for this module.

## Example

```hcl
module "dynamodb" {
  source = "git::https://github.com/your-org/your-terraform-modules.git//IDVH/dynamodb?ref=main"

  product_name       = "onemail"
  env                = "dev"
  idvh_resource_tier = "standard"

  table_name = "Sessions"
  hash_key   = "samlRequestID"
  range_key  = "recordType"

  attributes = [
    {
      name = "samlRequestID"
      type = "S"
    },
    {
      name = "recordType"
      type = "S"
    },
    {
      name = "code"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "gsi_code_idx"
      hash_key        = "code"
      projection_type = "ALL"
    }
  ]

  ttl_enabled                    = true
  ttl_attribute_name             = "ttl"
  point_in_time_recovery_enabled = true
  stream_enabled                 = true
  stream_view_type               = "NEW_AND_OLD_IMAGES"

  create_kms_key = true
  kms_alias      = "/dynamodb/sessions"
}
```
