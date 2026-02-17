locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  required_tier_keys = toset([
    "billing_mode",
    "point_in_time_recovery_enabled",
    "server_side_encryption_enabled",
    "deletion_protection_enabled",
    "table_class",
    "stream_enabled",
    "stream_view_type",
    "ttl_enabled",
    "ttl_attribute_name",
  ])

  valid_attribute_types = toset(["S", "N", "B"])
  attribute_names       = [for attribute in var.attributes : attribute.name]

  missing_tier_keys = setsubtract(local.required_tier_keys, toset(keys(local.idvh_config)))
}

check "dynamodb_yaml_required_keys" {
  assert {
    condition     = length(local.missing_tier_keys) == 0
    error_message = "Invalid dynamodb tier YAML. Missing required keys: [${join(", ", tolist(local.missing_tier_keys))}]"
  }
}

check "dynamodb_yaml_types" {
  assert {
    condition = (
      can(tostring(local.idvh_config.billing_mode)) &&
      can(tobool(local.idvh_config.point_in_time_recovery_enabled)) &&
      can(tobool(local.idvh_config.server_side_encryption_enabled)) &&
      can(tobool(local.idvh_config.deletion_protection_enabled)) &&
      can(tostring(local.idvh_config.table_class)) &&
      can(tobool(local.idvh_config.stream_enabled)) &&
      can(tostring(local.idvh_config.stream_view_type)) &&
      can(tobool(local.idvh_config.ttl_enabled)) &&
      can(tostring(local.idvh_config.ttl_attribute_name))
    )

    error_message = "Invalid dynamodb tier YAML types. Check billing, booleans, stream and ttl values."
  }
}

check "dynamodb_yaml_values" {
  assert {
    condition = (
      contains(["PAY_PER_REQUEST", "PROVISIONED"], local.idvh_config.billing_mode) &&
      contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], local.idvh_config.table_class) &&
      (
        local.idvh_config.stream_enabled ?
        contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], local.idvh_config.stream_view_type) :
        true
      ) &&
      (
        local.idvh_config.ttl_enabled ?
        length(trimspace(local.idvh_config.ttl_attribute_name)) > 0 :
        true
      )
    )

    error_message = "Invalid dynamodb tier YAML values. Check billing_mode/table_class and stream/ttl constraints."
  }
}

check "dynamodb_schema_values" {
  assert {
    condition = (
      length(var.attributes) > 0 &&
      length(var.attributes) == length(toset(local.attribute_names)) &&
      contains(local.attribute_names, var.hash_key) &&
      (var.range_key == null || contains(local.attribute_names, var.range_key)) &&
      alltrue([for attribute in var.attributes : contains(local.valid_attribute_types, attribute.type)]) &&
      (
        local.idvh_config.billing_mode == "PROVISIONED" ?
        var.read_capacity != null && var.read_capacity > 0 && var.write_capacity != null && var.write_capacity > 0 :
        true
      ) &&
      (
        local.idvh_config.billing_mode == "PAY_PER_REQUEST" ?
        var.read_capacity == null && var.write_capacity == null :
        true
      )
    )

    error_message = "Invalid dynamodb schema inputs. Ensure attributes include hash/range keys, use valid attribute types and align capacities with billing_mode."
  }
}
