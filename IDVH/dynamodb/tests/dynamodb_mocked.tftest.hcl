mock_provider "aws" {}

run "plan_with_minimal_table" {
  command = plan

  module {
    source = "./"
  }

  variables {
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
  }

  assert {
    condition     = output.table_name == "Sessions"
    error_message = "Expected table_name output to match the requested table name."
  }

  assert {
    condition     = output.kms_key_arn != null
    error_message = "Expected kms_key_arn output to be set when create_kms_key is true."
  }

  assert {
    condition     = output.idvh_tier_config != null
    error_message = "Expected idvh_tier_config output to contain tier configuration."
  }
}

run "plan_with_existing_kms_key" {
  command = plan

  module {
    source = "./"
  }

  variables {
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
    server_side_encryption_kms_key_arn = "arn:aws:kms:eu-south-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    enable_replication                 = false
  }

  assert {
    condition     = output.kms_key_arn == "arn:aws:kms:eu-south-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    error_message = "Expected kms_key_arn output to match the provided ARN."
  }

  assert {
    condition     = output.kms_key_id == null
    error_message = "Expected kms_key_id output to be null when create_kms_key is false."
  }
}

run "fails_when_hash_key_not_in_attributes" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "myproduct"
    env                = "dev"
    idvh_resource_tier = "standard"

    table_config = {
      table_name = "Sessions"
      hash_key   = "missingKey"
      attributes = [
        { name = "userId", type = "S" }
      ]
    }
  }

  expect_failures = [
    check.dynamodb_table_inputs,
  ]
}

run "fails_when_create_kms_key_without_alias" {
  command = plan

  module {
    source = "./"
  }

  variables {
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
    kms_alias      = null
    enable_replication = false
  }

  expect_failures = [
    check.dynamodb_kms_inputs,
  ]
}

run "plan_with_replica_without_explicit_kms_key" {
  command = plan

  module {
    source = "./"
  }

  variables {
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
        }
      ]
    }

    create_kms_key = true
    kms_alias      = "/dynamodb/email-status-history"
    enable_replication = true
  }

  assert {
    condition     = output.kms_key_arn != null
    error_message = "Expected kms_key_arn output to be set when create_kms_key is true."
  }
}