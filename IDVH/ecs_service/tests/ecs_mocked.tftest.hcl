mock_provider "aws" {}

override_data {
  target = data.aws_region.current
  values = {
    id   = "eu-west-1"
    name = "eu-west-1"
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

    service_name          = "onemail-dev-core"
    container_name        = "core"
    image                 = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/onemail-dev-core:1.0.0"
    cluster_arn           = "arn:aws:ecs:eu-west-1:123456789012:cluster/onemail-dev-ecs-cluster"
    private_subnets       = ["subnet-0123456789abcdef0"]
    target_group_arn      = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/core/1234567890abcdef"
    nlb_security_group_id = "sg-0123456789abcdef0"
  }

  assert {
    condition     = output.service_name == "onemail-dev-core"
    error_message = "Expected service_name output to match input service_name."
  }

  assert {
    condition     = output.log_group_name == "/aws/ecs/onemail-dev-core/core"
    error_message = "Expected log_group_name output to follow /aws/ecs/<service>/<container>."
  }
}

run "fails_when_service_name_is_empty" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    service_name          = ""
    container_name        = "core"
    image                 = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/onemail-dev-core:1.0.0"
    cluster_arn           = "arn:aws:ecs:eu-west-1:123456789012:cluster/onemail-dev-ecs-cluster"
    private_subnets       = ["subnet-0123456789abcdef0"]
    target_group_arn      = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/core/1234567890abcdef"
    nlb_security_group_id = "sg-0123456789abcdef0"
  }

  expect_failures = [
    check.ecs_dynamic_inputs,
  ]
}
