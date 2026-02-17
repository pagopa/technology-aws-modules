mock_provider "aws" {}

run "plan_with_standard_tier" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    name      = "onemail-dev-table"
    hash_key  = "pk"
    range_key = "sk"

    attributes = [
      {
        name = "pk"
        type = "S"
      },
      {
        name = "sk"
        type = "S"
      }
    ]
  }

  assert {
    condition     = output.table_name == "onemail-dev-table"
    error_message = "Expected table_name output to match the provided table name."
  }
}

run "fails_with_missing_hash_key_attribute" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    name      = "onemail-dev-table"
    hash_key  = "pk"
    range_key = "sk"

    attributes = [
      {
        name = "other_key"
        type = "S"
      }
    ]
  }

  expect_failures = [
    check.dynamodb_schema_values,
  ]
}
