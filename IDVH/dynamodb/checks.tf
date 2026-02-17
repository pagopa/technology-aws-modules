locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  required_tier_keys = toset([
    "kms_ssm_enable_rotation",
    "kms_rotation_period_in_days",
    "sessions_table",
    "client_registrations_table",
    "idp_metadata_table",
    "idp_status_history_table",
    "client_status_history_table",
    "last_idp_used_table",
    "internal_idp_users_table",
    "internal_idp_sessions",
  ])

  required_sessions_table_keys = toset([
    "ttl_enabled",
    "point_in_time_recovery_enabled",
    "stream_enabled",
    "stream_view_type",
    "deletion_protection_enabled",
  ])

  required_table_keys = toset([
    "point_in_time_recovery_enabled",
    "stream_enabled",
    "stream_view_type",
    "deletion_protection_enabled",
    "replication_regions",
  ])

  required_last_idp_used_table_keys = toset([
    "ttl_enabled",
    "point_in_time_recovery_enabled",
    "stream_enabled",
    "stream_view_type",
    "deletion_protection_enabled",
    "replication_regions",
  ])

  missing_tier_keys = setsubtract(local.required_tier_keys, toset(keys(local.idvh_config)))

  missing_sessions_table_keys = can(local.idvh_config.sessions_table) ? setsubtract(local.required_sessions_table_keys, toset(keys(local.idvh_config.sessions_table))) : local.required_sessions_table_keys

  missing_client_registrations_table_keys = can(local.idvh_config.client_registrations_table) ? setsubtract(local.required_table_keys, toset(keys(local.idvh_config.client_registrations_table))) : local.required_table_keys

  missing_idp_metadata_table_keys = can(local.idvh_config.idp_metadata_table) ? setsubtract(local.required_table_keys, toset(keys(local.idvh_config.idp_metadata_table))) : local.required_table_keys

  missing_idp_status_history_table_keys = can(local.idvh_config.idp_status_history_table) ? setsubtract(local.required_table_keys, toset(keys(local.idvh_config.idp_status_history_table))) : local.required_table_keys

  missing_client_status_history_table_keys = can(local.idvh_config.client_status_history_table) ? setsubtract(local.required_table_keys, toset(keys(local.idvh_config.client_status_history_table))) : local.required_table_keys

  missing_last_idp_used_table_keys = can(local.idvh_config.last_idp_used_table) ? setsubtract(local.required_last_idp_used_table_keys, toset(keys(local.idvh_config.last_idp_used_table))) : local.required_last_idp_used_table_keys

  missing_internal_idp_users_table_keys = can(local.idvh_config.internal_idp_users_table) ? setsubtract(local.required_sessions_table_keys, toset(keys(local.idvh_config.internal_idp_users_table))) : local.required_sessions_table_keys

  missing_internal_idp_sessions_keys = can(local.idvh_config.internal_idp_sessions) ? setsubtract(local.required_sessions_table_keys, toset(keys(local.idvh_config.internal_idp_sessions))) : local.required_sessions_table_keys

  valid_stream_view_types = toset(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"])
}

check "dynamodb_yaml_required_keys" {
  assert {
    condition = (
      length(local.missing_tier_keys) == 0 &&
      length(local.missing_sessions_table_keys) == 0 &&
      length(local.missing_client_registrations_table_keys) == 0 &&
      length(local.missing_idp_metadata_table_keys) == 0 &&
      length(local.missing_idp_status_history_table_keys) == 0 &&
      length(local.missing_client_status_history_table_keys) == 0 &&
      length(local.missing_last_idp_used_table_keys) == 0 &&
      length(local.missing_internal_idp_users_table_keys) == 0 &&
      length(local.missing_internal_idp_sessions_keys) == 0
    )

    error_message = "Invalid dynamodb tier YAML. Missing required keys in one or more table configurations."
  }
}

check "dynamodb_yaml_types" {
  assert {
    condition = (
      can(tobool(local.idvh_config.kms_ssm_enable_rotation)) &&
      can(tonumber(local.idvh_config.kms_rotation_period_in_days)) &&
      can(tobool(local.idvh_config.sessions_table.ttl_enabled)) &&
      can(tobool(local.idvh_config.sessions_table.point_in_time_recovery_enabled)) &&
      can(tobool(local.idvh_config.sessions_table.stream_enabled)) &&
      (local.idvh_config.sessions_table.stream_view_type == null || can(tostring(local.idvh_config.sessions_table.stream_view_type))) &&
      can(tobool(local.idvh_config.sessions_table.deletion_protection_enabled)) &&
      can(tobool(local.idvh_config.client_registrations_table.point_in_time_recovery_enabled)) &&
      can(tobool(local.idvh_config.client_registrations_table.stream_enabled)) &&
      (local.idvh_config.client_registrations_table.stream_view_type == null || can(tostring(local.idvh_config.client_registrations_table.stream_view_type))) &&
      can(tobool(local.idvh_config.client_registrations_table.deletion_protection_enabled)) &&
      can([for r in local.idvh_config.client_registrations_table.replication_regions : tostring(r.region_name)]) &&
      can(tobool(local.idvh_config.idp_metadata_table.point_in_time_recovery_enabled)) &&
      can(tobool(local.idvh_config.idp_metadata_table.stream_enabled)) &&
      (local.idvh_config.idp_metadata_table.stream_view_type == null || can(tostring(local.idvh_config.idp_metadata_table.stream_view_type))) &&
      can(tobool(local.idvh_config.idp_metadata_table.deletion_protection_enabled)) &&
      can([for r in local.idvh_config.idp_metadata_table.replication_regions : tostring(r.region_name)]) &&
      can(tobool(local.idvh_config.idp_status_history_table.point_in_time_recovery_enabled)) &&
      can(tobool(local.idvh_config.idp_status_history_table.stream_enabled)) &&
      (local.idvh_config.idp_status_history_table.stream_view_type == null || can(tostring(local.idvh_config.idp_status_history_table.stream_view_type))) &&
      can(tobool(local.idvh_config.idp_status_history_table.deletion_protection_enabled)) &&
      can([for r in local.idvh_config.idp_status_history_table.replication_regions : tostring(r.region_name)]) &&
      can(tobool(local.idvh_config.client_status_history_table.point_in_time_recovery_enabled)) &&
      can(tobool(local.idvh_config.client_status_history_table.stream_enabled)) &&
      (local.idvh_config.client_status_history_table.stream_view_type == null || can(tostring(local.idvh_config.client_status_history_table.stream_view_type))) &&
      can(tobool(local.idvh_config.client_status_history_table.deletion_protection_enabled)) &&
      can([for r in local.idvh_config.client_status_history_table.replication_regions : tostring(r.region_name)]) &&
      can(tobool(local.idvh_config.last_idp_used_table.ttl_enabled)) &&
      can(tobool(local.idvh_config.last_idp_used_table.point_in_time_recovery_enabled)) &&
      can(tobool(local.idvh_config.last_idp_used_table.stream_enabled)) &&
      (local.idvh_config.last_idp_used_table.stream_view_type == null || can(tostring(local.idvh_config.last_idp_used_table.stream_view_type))) &&
      can(tobool(local.idvh_config.last_idp_used_table.deletion_protection_enabled)) &&
      can([for r in local.idvh_config.last_idp_used_table.replication_regions : tostring(r.region_name)]) &&
      can(tobool(local.idvh_config.internal_idp_users_table.point_in_time_recovery_enabled)) &&
      can(tobool(local.idvh_config.internal_idp_users_table.stream_enabled)) &&
      (local.idvh_config.internal_idp_users_table.stream_view_type == null || can(tostring(local.idvh_config.internal_idp_users_table.stream_view_type))) &&
      can(tobool(local.idvh_config.internal_idp_users_table.deletion_protection_enabled)) &&
      can(tobool(local.idvh_config.internal_idp_sessions.point_in_time_recovery_enabled)) &&
      can(tobool(local.idvh_config.internal_idp_sessions.stream_enabled)) &&
      (local.idvh_config.internal_idp_sessions.stream_view_type == null || can(tostring(local.idvh_config.internal_idp_sessions.stream_view_type))) &&
      can(tobool(local.idvh_config.internal_idp_sessions.deletion_protection_enabled))
    )

    error_message = "Invalid dynamodb tier YAML types. Check KMS and all nested table configuration types."
  }
}

check "dynamodb_yaml_values" {
  assert {
    condition = (
      local.idvh_config.kms_rotation_period_in_days > 0 &&
      (
        local.idvh_config.sessions_table.stream_enabled ?
        contains(local.valid_stream_view_types, local.idvh_config.sessions_table.stream_view_type) :
        true
      ) &&
      (
        local.idvh_config.client_registrations_table.stream_enabled ?
        contains(local.valid_stream_view_types, local.idvh_config.client_registrations_table.stream_view_type) :
        true
      ) &&
      (
        local.idvh_config.idp_metadata_table.stream_enabled ?
        contains(local.valid_stream_view_types, local.idvh_config.idp_metadata_table.stream_view_type) :
        true
      ) &&
      (
        local.idvh_config.idp_status_history_table.stream_enabled ?
        contains(local.valid_stream_view_types, local.idvh_config.idp_status_history_table.stream_view_type) :
        true
      ) &&
      (
        local.idvh_config.client_status_history_table.stream_enabled ?
        contains(local.valid_stream_view_types, local.idvh_config.client_status_history_table.stream_view_type) :
        true
      ) &&
      (
        local.idvh_config.last_idp_used_table.stream_enabled ?
        contains(local.valid_stream_view_types, local.idvh_config.last_idp_used_table.stream_view_type) :
        true
      ) &&
      (
        local.idvh_config.internal_idp_users_table.stream_enabled ?
        contains(local.valid_stream_view_types, local.idvh_config.internal_idp_users_table.stream_view_type) :
        true
      ) &&
      (
        local.idvh_config.internal_idp_sessions.stream_enabled ?
        contains(local.valid_stream_view_types, local.idvh_config.internal_idp_sessions.stream_view_type) :
        true
      ) &&
      alltrue([for r in local.idvh_config.client_registrations_table.replication_regions : length(trimspace(r.region_name)) > 0]) &&
      alltrue([for r in local.idvh_config.idp_metadata_table.replication_regions : length(trimspace(r.region_name)) > 0]) &&
      alltrue([for r in local.idvh_config.idp_status_history_table.replication_regions : length(trimspace(r.region_name)) > 0]) &&
      alltrue([for r in local.idvh_config.client_status_history_table.replication_regions : length(trimspace(r.region_name)) > 0]) &&
      alltrue([for r in local.idvh_config.last_idp_used_table.replication_regions : length(trimspace(r.region_name)) > 0]) &&
      (
        var.idp_entity_ids != null ?
        alltrue([for idp_entity_id in var.idp_entity_ids : length(trimspace(idp_entity_id)) > 0]) :
        true
      ) &&
      (
        var.clients != null ?
        alltrue([for client in var.clients : length(trimspace(client.client_id)) > 0]) :
        true
      )
    )

    error_message = "Invalid dynamodb tier YAML values. Check stream view types, replication region names and dynamic item seed inputs."
  }
}
