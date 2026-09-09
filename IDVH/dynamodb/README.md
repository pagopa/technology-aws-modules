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
- Reads table behavior defaults from `dynamodb.yml` tier values (with optional per-call overrides in `table_config`)

IDVH rule: `dynamodb.yml` defines KMS and table defaults (`enable_point_in_time_recovery`, `billing_mode`, stream/ttl flags, GSI/LSI defaults, replica defaults).

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
    billing_mode                = optional(string)
    stream_enabled              = optional(bool)
    stream_view_type            = optional(string)
    ttl_enabled                 = optional(bool)
    ttl_attribute_name          = optional(string)
    deletion_protection_enabled = optional(bool)
    global_secondary_indexes    = optional(any)
    local_secondary_indexes     = optional(any)
    replica_regions = optional(list(object({
      region_name = string
      kms_key_arn = optional(string)
    })))
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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.63.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dynamodb_table"></a> [dynamodb\_table](#module\_dynamodb\_table) | git::https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table.git | 696ceabbfdd49f8246e3d401c035729d60ea6fab |
| <a name="module_idvh_loader"></a> [idvh\_loader](#module\_idvh\_loader) | ../01_idvh_loader | n/a |
| <a name="module_kms_table_key"></a> [kms\_table\_key](#module\_kms\_table\_key) | git::https://github.com/terraform-aws-modules/terraform-aws-kms.git | 8478d2dcaa81d60e6a21adeee4bc428290244f11 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_replica_key.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | (Required) Environment for which the resource will be created | `string` | n/a | yes |
| <a name="input_idvh_resource_tier"></a> [idvh\_resource\_tier](#input\_idvh\_resource\_tier) | (Required) The IDVH resource tier key to be created | `string` | n/a | yes |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | (Required) Product name used to identify the catalog to be used | `string` | n/a | yes |
| <a name="input_table_config"></a> [table\_config](#input\_table\_config) | (Required) DynamoDB table configuration passed to upstream module | <pre>object({<br/>    table_name                  = string<br/>    hash_key                    = string<br/>    range_key                   = optional(string)<br/>    attributes                  = list(object({ name = string, type = string }))<br/>    billing_mode                = optional(string)<br/>    stream_enabled              = optional(bool)<br/>    stream_view_type            = optional(string)<br/>    ttl_enabled                 = optional(bool)<br/>    ttl_attribute_name          = optional(string)<br/>    deletion_protection_enabled = optional(bool)<br/>    global_secondary_indexes    = optional(any)<br/>    local_secondary_indexes     = optional(any)<br/>    replica_regions = optional(list(object({<br/>      region_name = string<br/>      kms_key_arn = optional(string)<br/>    })))<br/>  })</pre> | n/a | yes |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | (Optional) Create a dedicated KMS key for DynamoDB table encryption | `bool` | `false` | no |
| <a name="input_enable_point_in_time_recovery"></a> [enable\_point\_in\_time\_recovery](#input\_enable\_point\_in\_time\_recovery) | (Optional) Enable point-in-time recovery. If null and idvh\_resource\_tier is set, the IDVH tier value is used. | `bool` | `null` | no |
| <a name="input_enable_replication"></a> [enable\_replication](#input\_enable\_replication) | (Optional) Enable DynamoDB global table replication and KMS multi-region settings | `bool` | `false` | no |
| <a name="input_kms_alias"></a> [kms\_alias](#input\_kms\_alias) | (Optional) KMS alias used when create\_kms\_key is true | `string` | `null` | no |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | (Optional) Description for the created KMS key | `string` | `"KMS key for DynamoDB table encryption."` | no |
| <a name="input_kms_enable_key_rotation"></a> [kms\_enable\_key\_rotation](#input\_kms\_enable\_key\_rotation) | (Optional) KMS rotation override. If null and create\_kms\_key is true, the IDVH tier value is used. | `bool` | `null` | no |
| <a name="input_kms_rotation_period_in_days"></a> [kms\_rotation\_period\_in\_days](#input\_kms\_rotation\_period\_in\_days) | (Optional) KMS rotation period override. If null and create\_kms\_key is true, the IDVH tier value is used. | `number` | `null` | no |
| <a name="input_server_side_encryption_kms_key_arn"></a> [server\_side\_encryption\_kms\_key\_arn](#input\_server\_side\_encryption\_kms\_key\_arn) | (Optional) Existing KMS key ARN used for table encryption when create\_kms\_key is false | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_idvh_tier_config"></a> [idvh\_tier\_config](#output\_idvh\_tier\_config) | IDVH tier configuration for DynamoDB |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | KMS key ARN for table encryption |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | KMS key ID if created by this module |
| <a name="output_table_arn"></a> [table\_arn](#output\_table\_arn) | DynamoDB table ARN |
| <a name="output_table_name"></a> [table\_name](#output\_table\_name) | DynamoDB table name |
<!-- END_TF_DOCS -->