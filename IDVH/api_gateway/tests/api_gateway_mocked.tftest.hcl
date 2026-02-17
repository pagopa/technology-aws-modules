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

    name = "onemail-dev-rest-api"
    body = jsonencode({
      openapi = "3.0.1"
      info = {
        title   = "test"
        version = "1.0.0"
      }
      paths = {}
    })
  }

  assert {
    condition     = output.rest_api_stage_name == "dev"
    error_message = "Expected rest_api_stage_name output to match tier stage_name."
  }
}

run "fails_with_custom_domain_missing_certificate" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    name               = "onemail-dev-rest-api"
    body               = jsonencode({ openapi = "3.0.1", info = { title = "test", version = "1.0.0" }, paths = {} })
    custom_domain_name = "api.dev.example.com"
  }

  expect_failures = [
    check.api_gateway_yaml_values,
  ]
}
