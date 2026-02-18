locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  required_tier_keys = toset([
    "kms_ssm_enable_rotation",
    "kms_rotation_period_in_days",
  ])

  missing_tier_keys = setsubtract(local.required_tier_keys, toset(keys(local.idvh_config)))

  valid_attribute_types = toset(["S", "N", "B"])

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

check "dynamodb_kms_inputs" {
  assert {
    condition = (
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

    error_message = "Invalid KMS configuration. When create_kms_key is true, kms_alias must be provided and rotation period must be greater than zero."
  }
}

check "dynamodb_table_inputs" {
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
      contains(local.attribute_names, var.hash_key)
    )

    error_message = "Invalid DynamoDB table configuration. Check table_name, hash_key, and attributes."
  }
}
