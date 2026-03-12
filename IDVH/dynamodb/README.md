# IDVH dynamodb

Wrapper module for DynamoDB tables that loads IDVH tier defaults and creates tables with KMS encryption plus common DynamoDB features.

This module:
- Loads IDVH tier configuration using `product_name`, `env`, and `idvh_resource_tier`
- Creates a DynamoDB table with required and optional parameters
- Optionally creates a KMS key for table encryption with tier-based rotation settings
- Always enables server-side encryption
- Supports range keys, GSI/LSI, TTL, streams, deletion protection, and global tables
- Automatically uses the module KMS key ARN for replicas when `kms_key_arn` is not explicitly set
- Keeps replication disabled by default and enables DynamoDB/KMS replication only when `enable_replication = true`

IDVH rule: `dynamodb.yml` keeps only KMS defaults (`kms_ssm_enable_rotation`, `kms_rotation_period_in_days`).

## IDVH resources available
[Here's](./LIBRARY.md) the list of `idvh_resource_tier` available for this module.

## Example - Basic table

```hcl
module "dynamodb" {
  source = "git::https://github.com/pagopa/technology-aws-modules.git//IDVH/dynamodb?ref=main"

  product_name       = "myproduct"
  env                = "dev"
  idvh_resource_tier = "standard"

  table_config = {
    table_name = "Sessions"
    hash_key   = "sessionId"
    attributes = [
      { name = "sessionId", type = "S" }
    ]
  }

  create_kms_key = true
  kms_alias      = "/dynamodb/sessions"
  enable_replication = false

  tags = {
    Project = "MyProject"
  }
}
```

## Example - Full-featured table

```hcl
module "dynamodb" {
  source = "git::https://github.com/pagopa/technology-aws-modules.git//IDVH/dynamodb?ref=main"

  product_name       = "myproduct"
  env                = "dev"
  idvh_resource_tier = "standard"

  table_config = {
    table_name = "Orders"
    hash_key   = "orderId"
    range_key  = "createdAt"
    attributes = [
      { name = "orderId", type = "S" },
      { name = "createdAt", type = "S" },
      { name = "customerId", type = "S" }
    ]
    billing_mode = "PAY_PER_REQUEST"
    global_secondary_indexes = [
      {
        name            = "CustomerIndex"
        hash_key        = "customerId"
        projection_type = "ALL"
      }
    ]
    ttl_enabled                 = true
    ttl_attribute_name          = "expiresAt"
    stream_enabled              = true
    stream_view_type            = "NEW_AND_OLD_IMAGES"
    deletion_protection_enabled = true
  }

  enable_point_in_time_recovery = true

  create_kms_key = true
  kms_alias      = "/dynamodb/orders"

  tags = {
    Project = "MyProject"
  }
}
```

## Example - Global table with replicas

When `replica_regions` is set and a customer-managed KMS key is used, the module uses the created table KMS key ARN by default for each replica. You can still override `kms_key_arn` per replica region when needed.

```hcl
module "dynamodb" {
  source = "git::https://github.com/pagopa/technology-aws-modules.git//IDVH/dynamodb?ref=main"

  product_name       = "myproduct"
  env                = "dev"
  idvh_resource_tier = "standard"

  table_config = {
    table_name = "EmailStatusHistory"
    hash_key   = "statusId"
    attributes = [
      { name = "statusId", type = "S" }
    ]
    replica_regions = [
      {
        region_name = "eu-central-1"
        kms_key_arn = "arn:aws:kms:eu-central-1:123456789012:key/replica-key-id"
      }
    ]
  }

  create_kms_key = true
  kms_alias      = "/dynamodb/email-status-history"
}
```

## Example - Pass-through from variable

```hcl
variable "dynamodb_table_config" {
  type = object({
    table_name                  = string
    hash_key                    = string
    range_key                   = optional(string)
    attributes                  = list(object({ name = string, type = string }))
    billing_mode                = optional(string, "PAY_PER_REQUEST")
    stream_enabled              = optional(bool, false)
    stream_view_type            = optional(string)
    ttl_enabled                 = optional(bool, false)
    ttl_attribute_name          = optional(string, "")
    deletion_protection_enabled = optional(bool, false)
    global_secondary_indexes    = optional(any, [])
    local_secondary_indexes     = optional(any, [])
    replica_regions = optional(list(object({
      region_name = string
      kms_key_arn = optional(string)
    })), [])
  })
}

module "dynamodb" {
  count  = var.dynamodb_table_config != null ? 1 : 0
  source = "git::https://github.com/pagopa/technology-aws-modules.git//IDVH/dynamodb?ref=main"

  product_name       = "myproduct"
  env                = var.env
  idvh_resource_tier = "standard"

  table_config = var.dynamodb_table_config

  create_kms_key = true
  kms_alias      = "/dynamodb/${var.dynamodb_table_config.table_name}"
  enable_replication = false

  tags = var.tags
}
```

## Example - Using an existing KMS key

```hcl
module "dynamodb" {
  source = "git::https://github.com/pagopa/technology-aws-modules.git//IDVH/dynamodb?ref=main"

  product_name       = "myproduct"
  env                = "dev"
  idvh_resource_tier = "standard"

  table_config = {
    table_name = "Sessions"
    hash_key   = "userId"
    attributes = [
      { name = "userId", type = "S" }
    ]
  }

  create_kms_key                     = false
  server_side_encryption_kms_key_arn = "arn:aws:kms:eu-south-1:123456789012:key/existing-key-id"
  enable_replication                 = false
}
```
