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

    name = "onemail-dev-events"
  }

  assert {
    condition     = output.queue_name == "onemail-dev-events"
    error_message = "Expected queue_name output to match requested queue name."
  }

  assert {
    condition     = output.dead_letter_queue_name == "onemail-dev-events-dlq"
    error_message = "Expected DLQ name derived from queue name and dead_letter_queue.name_suffix."
  }
}

run "fails_with_invalid_visibility_timeout_override" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    name                       = "onemail-dev-events"
    visibility_timeout_seconds = 50000
  }

  expect_failures = [
    check.sqs_yaml_values,
  ]
}
