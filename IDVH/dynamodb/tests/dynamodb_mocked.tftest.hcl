mock_provider "aws" {}

run "plan_with_single_table" {
  command = plan

  module {
    source = "./"
  }

  variables {
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
    deletion_protection_enabled    = false
    server_side_encryption_enabled = true
    create_kms_key                 = true
    kms_alias                      = "/dynamodb/sessions"
  }

  assert {
    condition     = output.table_name == "Sessions"
    error_message = "Expected table_name output to match the requested table name."
  }

  assert {
    condition     = output.table_global_secondary_index_arns["gsi_code_idx"] == "${output.table_arn}/index/gsi_code_idx"
    error_message = "Expected GSI ARN output to be composed from table ARN and index name."
  }

  assert {
    condition     = output.kms_key_arn != null
    error_message = "Expected kms_key_arn output to be set when create_kms_key is true."
  }
}

run "fails_when_stream_enabled_without_stream_view_type" {
  command = plan

  module {
    source = "./"
  }

  variables {
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
      }
    ]

    stream_enabled   = true
    stream_view_type = null
  }

  expect_failures = [
    check.dynamodb_module_values,
  ]
}
