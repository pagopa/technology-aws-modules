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

    idp_entity_ids = ["https://idp.example.com/metadata"]

    clients = [
      {
        client_id     = "client-app"
        friendly_name = "Client App"
      }
    ]
  }

  assert {
    condition     = output.table_sessions_name == "Sessions"
    error_message = "Expected sessions table output to match the aligned module settings."
  }

  assert {
    condition     = output.table_client_registrations_name == "ClientRegistrations"
    error_message = "Expected client registrations table output to match the aligned module settings."
  }
}

run "fails_with_empty_idp_entity_id" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    idp_entity_ids = [""]
  }

  expect_failures = [
    check.dynamodb_yaml_values,
  ]
}
