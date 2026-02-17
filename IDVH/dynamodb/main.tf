module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "dynamodb"
}

locals {
  kms_sessions_table_alias = "/dynamodb/sessions"
  gsi_code                 = "gsi_code_idx"
  gsi_pointer              = "gsi_pointer_idx"
  gsi_namespace            = "gsi_namespace_idx"
}

module "kms_sessions_table" {
  source  = "terraform-aws-modules/kms/aws"
  version = "3.0.0"

  description             = "KMS key for Dynamodb table encryption."
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = local.idvh_config.kms_ssm_enable_rotation
  rotation_period_in_days = local.idvh_config.kms_rotation_period_in_days

  aliases = [local.kms_sessions_table_alias]

  tags = merge(
    var.tags,
    {
      Name = "kms-sessions-table"
    }
  )
}

module "dynamodb_sessions_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.0.1"

  name = "Sessions"

  hash_key  = "samlRequestID"
  range_key = "recordType"

  global_secondary_indexes = [
    {
      name            = local.gsi_code
      hash_key        = "code"
      projection_type = "ALL"
    }
  ]

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

  ttl_attribute_name = "ttl"
  ttl_enabled        = local.idvh_config.sessions_table.ttl_enabled

  billing_mode = "PAY_PER_REQUEST"

  point_in_time_recovery_enabled = local.idvh_config.sessions_table.point_in_time_recovery_enabled

  server_side_encryption_enabled = true
  server_side_encryption_kms_key_arn = module.kms_sessions_table.aliases[
    local.kms_sessions_table_alias
  ].target_key_arn

  stream_enabled              = local.idvh_config.sessions_table.stream_enabled
  stream_view_type            = local.idvh_config.sessions_table.stream_view_type
  deletion_protection_enabled = local.idvh_config.sessions_table.deletion_protection_enabled

  tags = merge(
    var.tags,
    {
      Name = "Session"
    }
  )
}

module "dynamodb_table_client_registrations" {
  count   = local.idvh_config.client_registrations_table != null ? 1 : 0
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.0.1"

  name = "ClientRegistrations"

  hash_key = "clientId"

  attributes = [
    {
      name = "clientId"
      type = "S"
    }
  ]

  billing_mode = "PAY_PER_REQUEST"

  point_in_time_recovery_enabled = local.idvh_config.client_registrations_table.point_in_time_recovery_enabled
  stream_enabled                 = local.idvh_config.client_registrations_table.stream_enabled
  stream_view_type               = local.idvh_config.client_registrations_table.stream_view_type
  replica_regions                = local.idvh_config.client_registrations_table.replication_regions
  deletion_protection_enabled    = local.idvh_config.client_registrations_table.deletion_protection_enabled

  tags = merge(
    var.tags,
    {
      Name = "ClientRegistrations"
    }
  )
}

data "aws_dynamodb_table" "dynamodb_table_client_registrations" {
  count = local.idvh_config.client_registrations_table == null ? 1 : 0
  name  = "ClientRegistrations"
}

module "dynamodb_table_idp_metadata" {
  count   = local.idvh_config.idp_metadata_table != null ? 1 : 0
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.0.1"

  name = "IDPMetadata"

  hash_key  = "entityID"
  range_key = "pointer"

  global_secondary_indexes = [
    {
      name            = local.gsi_pointer
      hash_key        = "pointer"
      projection_type = "ALL"
    }
  ]

  attributes = [
    {
      name = "entityID"
      type = "S"
    },
    {
      name = "pointer"
      type = "S"
    },
  ]

  billing_mode = "PAY_PER_REQUEST"

  point_in_time_recovery_enabled = local.idvh_config.idp_metadata_table.point_in_time_recovery_enabled
  stream_enabled                 = local.idvh_config.idp_metadata_table.stream_enabled
  stream_view_type               = local.idvh_config.idp_metadata_table.stream_view_type
  replica_regions                = local.idvh_config.idp_metadata_table.replication_regions
  deletion_protection_enabled    = local.idvh_config.idp_metadata_table.deletion_protection_enabled

  tags = merge(
    var.tags,
    {
      Name = "IDPMetadata"
    }
  )
}

data "aws_dynamodb_table" "dynamodb_table_idp_status_history" {
  count = local.idvh_config.idp_status_history_table == null ? 1 : 0
  name  = "IDPStatusHistory"
}

module "dynamodb_table_idp_status_history" {
  count   = local.idvh_config.idp_status_history_table != null ? 1 : 0
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.0.1"

  name = "IDPStatusHistory"

  hash_key  = "entityID"
  range_key = "pointer"

  global_secondary_indexes = [
    {
      name            = local.gsi_pointer
      hash_key        = "pointer"
      projection_type = "ALL"
    }
  ]

  attributes = [
    {
      name = "entityID"
      type = "S"
    },
    {
      name = "pointer"
      type = "S"
    },
  ]

  billing_mode = "PAY_PER_REQUEST"

  point_in_time_recovery_enabled = local.idvh_config.idp_status_history_table.point_in_time_recovery_enabled
  stream_enabled                 = local.idvh_config.idp_status_history_table.stream_enabled
  stream_view_type               = local.idvh_config.idp_status_history_table.stream_view_type
  replica_regions                = local.idvh_config.idp_status_history_table.replication_regions
  deletion_protection_enabled    = local.idvh_config.idp_status_history_table.deletion_protection_enabled

  tags = merge(
    var.tags,
    {
      Name = "IDPStatusHistory"
    }
  )
}

resource "aws_dynamodb_table_item" "default_idp_status_history_item" {
  table_name = module.dynamodb_table_idp_status_history[0].dynamodb_table_id
  hash_key   = "entityID"
  range_key  = "pointer"

  lifecycle {
    ignore_changes = [item]
  }

  for_each = var.idp_entity_ids != null ? { for idp_entity_id in var.idp_entity_ids : idp_entity_id => idp_entity_id } : {}

  item = <<ITEM
  {
    "entityID": {"S": "${each.key}"},
    "pointer": {"S": "latest"},
    "idpStatus": {"S": "OK"}
  }
  ITEM
}

data "aws_dynamodb_table" "dynamodb_table_client_status_history" {
  count = local.idvh_config.client_status_history_table == null ? 1 : 0
  name  = "ClientStatusHistory"
}

module "dynamodb_table_client_status_history" {
  count   = local.idvh_config.client_status_history_table != null ? 1 : 0
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.0.1"

  name = "ClientStatusHistory"

  hash_key  = "clientID"
  range_key = "pointer"

  global_secondary_indexes = [
    {
      name            = local.gsi_pointer
      hash_key        = "pointer"
      projection_type = "ALL"
    }
  ]

  attributes = [
    {
      name = "clientID"
      type = "S"
    },
    {
      name = "pointer"
      type = "S"
    },
  ]

  billing_mode = "PAY_PER_REQUEST"

  point_in_time_recovery_enabled = local.idvh_config.client_status_history_table.point_in_time_recovery_enabled
  stream_enabled                 = local.idvh_config.client_status_history_table.stream_enabled
  stream_view_type               = local.idvh_config.client_status_history_table.stream_view_type
  replica_regions                = local.idvh_config.client_status_history_table.replication_regions
  deletion_protection_enabled    = local.idvh_config.client_status_history_table.deletion_protection_enabled

  tags = merge(
    var.tags,
    {
      Name = "ClientStatusHistory"
    }
  )
}

resource "aws_dynamodb_table_item" "default_client_status_history_item" {
  table_name = module.dynamodb_table_client_status_history[0].dynamodb_table_id
  hash_key   = "clientID"
  range_key  = "pointer"

  lifecycle {
    ignore_changes = [item]
  }

  for_each = var.clients != null ? { for client in var.clients : client.client_id => client } : {}

  item = <<ITEM
  {
    "clientID": {"S": "${each.key}"},
    "pointer": {"S": "latest"},
    "clientStatus": {"S": "OK"}
  }
  ITEM
}

data "aws_dynamodb_table" "dynamodb_table_last_idp_used" {
  count = local.idvh_config.last_idp_used_table == null ? 1 : 0
  name  = "LastIDPUsed"
}

module "dynamodb_table_last_idp_used" {
  count   = local.idvh_config.last_idp_used_table != null ? 1 : 0
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.0.1"

  name = "LastIDPUsed"

  hash_key  = "id"
  range_key = "clientId"

  attributes = [
    {
      name = "id"
      type = "S"
    },
    {
      name = "clientId"
      type = "S"
    }
  ]

  ttl_attribute_name = "ttl"
  ttl_enabled        = local.idvh_config.last_idp_used_table.ttl_enabled

  billing_mode = "PAY_PER_REQUEST"

  point_in_time_recovery_enabled = local.idvh_config.last_idp_used_table.point_in_time_recovery_enabled
  stream_enabled                 = local.idvh_config.last_idp_used_table.stream_enabled
  stream_view_type               = local.idvh_config.last_idp_used_table.stream_view_type
  replica_regions                = local.idvh_config.last_idp_used_table.replication_regions
  deletion_protection_enabled    = local.idvh_config.last_idp_used_table.deletion_protection_enabled

  tags = merge(
    var.tags,
    {
      Name = "LastIDPUsed"
    }
  )
}

module "dynamodb_table_internal_idp_users" {
  count   = local.idvh_config.internal_idp_users_table != null ? 1 : 0
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.0.1"

  name = "InternalIDPUsers"

  hash_key  = "username"
  range_key = "namespace"

  attributes = [
    {
      name = "username"
      type = "S"
    },
    {
      name = "namespace"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = local.gsi_namespace
      hash_key        = "namespace"
      projection_type = "ALL"
    }
  ]

  billing_mode = "PAY_PER_REQUEST"

  point_in_time_recovery_enabled = local.idvh_config.internal_idp_users_table.point_in_time_recovery_enabled
  stream_enabled                 = local.idvh_config.internal_idp_users_table.stream_enabled
  stream_view_type               = local.idvh_config.internal_idp_users_table.stream_view_type
  deletion_protection_enabled    = local.idvh_config.internal_idp_users_table.deletion_protection_enabled

  tags = merge(
    var.tags,
    {
      Name = "InternalIDPUsers"
    }
  )
}

module "dynamodb_table_internal_idp_sessions" {
  count   = local.idvh_config.internal_idp_sessions != null ? 1 : 0
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.0.1"

  name = "InternalIDPSessions"

  hash_key  = "authnRequestId"
  range_key = "clientId"

  attributes = [
    {
      name = "authnRequestId"
      type = "S"
    },
    {
      name = "clientId"
      type = "S"
    }
  ]

  billing_mode = "PAY_PER_REQUEST"

  point_in_time_recovery_enabled = local.idvh_config.internal_idp_sessions.point_in_time_recovery_enabled
  stream_enabled                 = local.idvh_config.internal_idp_sessions.stream_enabled
  stream_view_type               = local.idvh_config.internal_idp_sessions.stream_view_type
  deletion_protection_enabled    = local.idvh_config.internal_idp_sessions.deletion_protection_enabled

  tags = merge(
    var.tags,
    {
      Name = "InternalIDPSessions"
    }
  )
}
