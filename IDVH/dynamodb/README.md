# IDVH dynamodb

Minimal wrapper module for DynamoDB tables that loads IDVH tier defaults and creates basic tables with KMS encryption.

This module:
- Loads IDVH tier configuration using `product_name`, `env`, and `idvh_resource_tier`
- Creates a DynamoDB table with basic required parameters (`name`, `hash_key`, `attributes`)
- Optionally creates a KMS key for table encryption with tier-based rotation settings
- Always enables server-side encryption

**Minimal design**: This module exposes only the required parameters from the AWS DynamoDB module (`table_name`, `hash_key`, `attributes`) plus KMS configuration. All optional features use AWS module defaults.

**For advanced features**: If you need to configure optional features like:
- Range keys
- Global/Local secondary indexes
- Billing mode (PAY_PER_REQUEST vs PROVISIONED)
- TTL, streams, point-in-time recovery
- Deletion protection
- Global tables

Use the `terraform-aws-modules/dynamodb-table/aws` module directly.

IDVH rule: `dynamodb.yml` keeps only KMS defaults (`kms_ssm_enable_rotation`, `kms_rotation_period_in_days`).

## IDVH resources available
[Here's](./LIBRARY.md) the list of `idvh_resource_tier` available for this module.

## Example - Basic table

```hcl
module "dynamodb" {
  source = "git::https://github.com/your-org/your-terraform-modules.git//IDVH/dynamodb?ref=main"

  product_name       = "onemail"
  env                = "dev"
  idvh_resource_tier = "standard"

  table_name = "Sessions"
  hash_key   = "samlRequestID"

  attributes = [
    {
      name = "samlRequestID"
      type = "S"
    }
  ]

  create_kms_key = true
  kms_alias      = "/dynamodb/sessions"

  tags = {
    Project = "OneM"
  }
}
```

## Example - Using an existing KMS key

```hcl
module "dynamodb" {
  source = "git::https://github.com/your-org/your-terraform-modules.git//IDVH/dynamodb?ref=main"

  product_name       = "onemail"
  env                = "dev"
  idvh_resource_tier = "standard"

  table_name = "Sessions"
  hash_key   = "userId"

  attributes = [
    {
      name = "userId"
      type = "S"
    }
  ]

  create_kms_key                      = false
  server_side_encryption_kms_key_arn = "arn:aws:kms:eu-south-1:123456789012:key/existing-key-id"
}
```

## Example - Advanced use case (use AWS module directly)

For tables requiring advanced features, skip this wrapper and use the AWS module:

```hcl
# Get IDVH tier config
module "dynamodb_config" {
  source = "git::https://github.com/your-org/your-terraform-modules.git//IDVH/dynamodb?ref=main"

  product_name       = "onemail"
  env                = "dev"
  idvh_resource_tier = "standard"

  table_name = "dummy"  # required but unused
  hash_key   = "id"
  attributes = [{ name = "id", type = "S" }]

  create_kms_key = true
  kms_alias      = "/dynamodb/sessions"
}

# Create advanced table with AWS module directly
module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 4.0"

  name      = "Sessions"
  hash_key  = "samlRequestID"
  range_key = "recordType"

  attributes = [
    { name = "samlRequestID", type = "S" },
    { name = "recordType", type = "S" },
    { name = "code", type = "S" }
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

  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = module.dynamodb_config.kms_key_arn

  tags = {
    Product = "onemail"
    Env     = "dev"
  }
}
```
