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

    name = "onemail-dev-http-api"
  }

  assert {
    condition     = output.stage_name == "dev"
    error_message = "Expected stage_name output to match tier stage_name."
  }

  assert {
    condition     = output.access_log_group_name == "/aws/apigateway/onemail-dev-http-api/dev"
    error_message = "Expected access log group name derived from api name and stage."
  }
}

run "fails_with_empty_access_log_format_override" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    name              = "onemail-dev-http-api"
    access_log_format = ""
  }

  expect_failures = [
    check.api_gateway_yaml_values,
  ]
}
