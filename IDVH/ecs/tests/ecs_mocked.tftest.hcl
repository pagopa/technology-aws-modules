mock_provider "aws" {}

override_data {
  target = data.aws_region.current
  values = {
    id   = "eu-west-1"
    name = "eu-west-1"
  }
}

override_data {
  target = data.aws_caller_identity.current
  values = {
    account_id = "123456789012"
    arn        = "arn:aws:iam::123456789012:user/mock"
    id         = "AIDAMOCKUSER"
    user_id    = "AIDAMOCKUSER"
  }
}

run "plan_with_standard_tier" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    vpc_id = "vpc-0123456789abcdef0"
    private_subnets = [
      "subnet-0123456789abcdef0",
      "subnet-abcdef0123456789a",
    ]
    vpc_cidr_block = "10.0.0.0/16"

    service_core_image_version = "1.0.0"
  }

  assert {
    condition     = output.ecs_cluster_name == "onemail-dev-ecs-cluster"
    error_message = "Expected ecs_cluster_name output to match tier ecs_cluster_name."
  }

  assert {
    condition     = output.core_service_name == "onemail-dev-core"
    error_message = "Expected core_service_name output to match tier service_core.service_name."
  }

  assert {
    condition     = output.internal_idp_service_name == null
    error_message = "Expected internal_idp_service_name output to be null when internal IDP is disabled in the selected tier."
  }
}

run "fails_when_internal_idp_enabled_without_image_version" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    vpc_id = "vpc-0123456789abcdef0"
    private_subnets = [
      "subnet-0123456789abcdef0",
    ]
    vpc_cidr_block = "10.0.0.0/16"

    service_core_image_version = "1.0.0"
    internal_idp_enabled       = true
  }

  expect_failures = [
    check.ecs_dynamic_inputs,
  ]
}
