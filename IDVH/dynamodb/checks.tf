locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  required_tier_keys = toset([
    "kms_ssm_enable_rotation",
    "kms_rotation_period_in_days",
  ])

  missing_tier_keys = setsubtract(local.required_tier_keys, toset(keys(local.idvh_config)))

  valid_stream_view_types = toset(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"])
  valid_attribute_types   = toset(["S", "N", "B"])
  valid_billing_modes     = toset(["PAY_PER_REQUEST", "PROVISIONED"])

  attribute_names = [for attribute in var.attributes : attribute.name]
}

check "dynamodb_yaml_required_keys" {
  assert {
    condition = length(local.missing_tier_keys) == 0

    error_message = "Invalid dynamodb tier YAML. Missing required keys: [${join(", ", tolist(local.missing_tier_keys))}]"
  }
}

check "dynamodb_yaml_types" {
  assert {
    condition = (
      can(tobool(local.idvh_config.kms_ssm_enable_rotation)) &&
      can(tonumber(local.idvh_config.kms_rotation_period_in_days))
    )

    error_message = "Invalid dynamodb tier YAML types. Check kms_ssm_enable_rotation and kms_rotation_period_in_days values."
  }
}

check "dynamodb_yaml_values" {
  assert {
    condition = local.idvh_config.kms_rotation_period_in_days > 0

    error_message = "Invalid dynamodb tier YAML values. kms_rotation_period_in_days must be greater than zero."
  }
}

check "dynamodb_module_values" {
  assert {
    condition = (
      length(trimspace(var.table_name)) > 0 &&
      length(trimspace(var.hash_key)) > 0 &&
      length(var.attributes) > 0 &&
      length(local.attribute_names) == length(distinct(local.attribute_names)) &&
      alltrue([
        for attribute in var.attributes :
        length(trimspace(attribute.name)) > 0 && contains(local.valid_attribute_types, attribute.type)
      ]) &&
      contains(local.attribute_names, var.hash_key) &&
      (var.range_key == null || contains(local.attribute_names, var.range_key)) &&
      contains(local.valid_billing_modes, var.billing_mode) &&
      (
        var.billing_mode == "PROVISIONED" ?
        var.read_capacity != null && var.write_capacity != null && var.read_capacity > 0 && var.write_capacity > 0 :
        var.read_capacity == null && var.write_capacity == null
      ) &&
      (
        var.ttl_enabled ?
        var.ttl_attribute_name != null && length(trimspace(var.ttl_attribute_name)) > 0 :
        true
      ) &&
      (
        var.stream_enabled ?
        var.stream_view_type != null && contains(local.valid_stream_view_types, var.stream_view_type) :
        var.stream_view_type == null
      ) &&
      alltrue([
        for region in var.replication_regions :
        length(trimspace(region.region_name)) > 0
      ]) &&
      length(distinct([
        for gsi in var.global_secondary_indexes :
        gsi.name
      ])) == length(var.global_secondary_indexes) &&
      alltrue([
        for gsi in var.global_secondary_indexes :
        length(trimspace(gsi.name)) > 0 &&
        length(trimspace(gsi.hash_key)) > 0 &&
        contains(local.attribute_names, gsi.hash_key) &&
        (try(gsi.range_key, null) == null || contains(local.attribute_names, gsi.range_key)) &&
        contains(["ALL", "KEYS_ONLY", "INCLUDE"], gsi.projection_type) &&
        (
          gsi.projection_type == "INCLUDE" ?
          try(length(gsi.non_key_attributes), 0) > 0 :
          true
        ) &&
        (
          var.billing_mode == "PROVISIONED" ?
          try(gsi.read_capacity, null) != null &&
          try(gsi.write_capacity, null) != null &&
          gsi.read_capacity > 0 &&
          gsi.write_capacity > 0 :
          try(gsi.read_capacity, null) == null &&
          try(gsi.write_capacity, null) == null
        )
      ]) &&
      length(distinct([
        for lsi in var.local_secondary_indexes :
        lsi.name
      ])) == length(var.local_secondary_indexes) &&
      (
        length(var.local_secondary_indexes) > 0 ?
        var.range_key != null :
        true
      ) &&
      alltrue([
        for lsi in var.local_secondary_indexes :
        length(trimspace(lsi.name)) > 0 &&
        contains(local.attribute_names, lsi.range_key) &&
        contains(["ALL", "KEYS_ONLY", "INCLUDE"], lsi.projection_type) &&
        (
          lsi.projection_type == "INCLUDE" ?
          try(length(lsi.non_key_attributes), 0) > 0 :
          true
        )
      ]) &&
      (
        var.create_kms_key ?
        var.kms_alias != null && length(trimspace(var.kms_alias)) > 0 :
        true
      ) &&
      (
        !var.create_kms_key ?
        (var.server_side_encryption_kms_key_arn == null || length(trimspace(var.server_side_encryption_kms_key_arn)) > 0) :
        true
      ) &&
      (
        var.create_kms_key ?
        local.effective_kms_rotation_period_in_days > 0 :
        true
      )
    )

    error_message = "Invalid dynamodb module inputs. Check table schema, stream/billing settings, index definitions and KMS parameters."
  }
}
