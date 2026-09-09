locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  required_tier_keys = toset([
    "fifo_queue",
    "content_based_deduplication",
    "delay_seconds",
    "max_message_size",
    "message_retention_seconds",
    "receive_wait_time_seconds",
    "visibility_timeout_seconds",
    "sqs_managed_sse_enabled",
    "kms_data_key_reuse_period_seconds",
    "dead_letter_queue",
  ])

  required_dead_letter_queue_keys = toset([
    "enabled",
    "max_receive_count",
    "name_suffix",
  ])

  missing_tier_keys              = setsubtract(local.required_tier_keys, toset(keys(local.idvh_config)))
  missing_dead_letter_queue_keys = can(local.idvh_config.dead_letter_queue) ? setsubtract(local.required_dead_letter_queue_keys, toset(keys(local.idvh_config.dead_letter_queue))) : local.required_dead_letter_queue_keys
}

check "sqs_yaml_required_keys" {
  assert {
    condition = (
      length(local.missing_tier_keys) == 0 &&
      length(local.missing_dead_letter_queue_keys) == 0
    )

    error_message = "Invalid sqs tier YAML. Missing required keys. tier: [${join(", ", tolist(local.missing_tier_keys))}] dead_letter_queue: [${join(", ", tolist(local.missing_dead_letter_queue_keys))}]"
  }
}

check "sqs_yaml_types" {
  assert {
    condition = (
      can(tobool(local.idvh_config.fifo_queue)) &&
      can(tobool(local.idvh_config.content_based_deduplication)) &&
      can(tonumber(local.idvh_config.delay_seconds)) &&
      can(tonumber(local.idvh_config.max_message_size)) &&
      can(tonumber(local.idvh_config.message_retention_seconds)) &&
      can(tonumber(local.idvh_config.receive_wait_time_seconds)) &&
      can(tonumber(local.idvh_config.visibility_timeout_seconds)) &&
      can(tobool(local.idvh_config.sqs_managed_sse_enabled)) &&
      can(tonumber(local.idvh_config.kms_data_key_reuse_period_seconds)) &&
      can(tobool(local.idvh_config.dead_letter_queue.enabled)) &&
      can(tonumber(local.idvh_config.dead_letter_queue.max_receive_count)) &&
      can(tostring(local.idvh_config.dead_letter_queue.name_suffix))
    )

    error_message = "Invalid sqs tier YAML types. Check queue booleans/numbers and dead_letter_queue nested values."
  }
}

check "sqs_yaml_values" {
  assert {
    condition = (
      local.idvh_config.delay_seconds >= 0 &&
      local.idvh_config.delay_seconds <= 900 &&
      local.idvh_config.max_message_size >= 1024 &&
      local.idvh_config.max_message_size <= 262144 &&
      local.idvh_config.message_retention_seconds >= 60 &&
      local.idvh_config.message_retention_seconds <= 1209600 &&
      local.idvh_config.receive_wait_time_seconds >= 0 &&
      local.idvh_config.receive_wait_time_seconds <= 20 &&
      local.effective_visibility_timeout_seconds >= 0 &&
      local.effective_visibility_timeout_seconds <= 43200 &&
      local.idvh_config.kms_data_key_reuse_period_seconds >= 60 &&
      local.idvh_config.kms_data_key_reuse_period_seconds <= 86400 &&
      (local.idvh_config.fifo_queue || !local.idvh_config.content_based_deduplication) &&
      (
        local.idvh_config.dead_letter_queue.enabled ?
        local.idvh_config.dead_letter_queue.max_receive_count >= 1 :
        true
      ) &&
      length(trimspace(local.idvh_config.dead_letter_queue.name_suffix)) > 0
    )

    error_message = "Invalid sqs tier YAML values. Check SQS limits, FIFO constraints, visibility timeout override and dead-letter queue settings."
  }
}
