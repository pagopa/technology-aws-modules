mock_provider "aws" {}

override_data {
  target = data.aws_region.current
  values = {
    id   = "eu-west-1"
    name = "eu-west-1"
  }
}

run "plan_single_service" {
  command = plan

  module {
    source = "./"
  }

  variables {
    service_name = "onemail-dev-core"
    cluster_arn  = "arn:aws:ecs:eu-west-1:123456789012:cluster/onemail-dev-ecs-cluster"

    cpu                    = 1024
    memory                 = 2048
    enable_execute_command = true

    container_name = "core"
    container_cpu  = 512
    container_port = 8080
    host_port      = 8080
    image          = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/onemail-dev-core:1.0.0"

    logs_retention_days = 14

    autoscaling = {
      enable        = true
      desired_count = 1
      min_capacity  = 1
      max_capacity  = 2
    }

    private_subnets       = ["subnet-0123456789abcdef0"]
    target_group_arn      = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/core/1234567890abcdef"
    nlb_security_group_id = "sg-0123456789abcdef0"
  }

  assert {
    condition     = output.name == "onemail-dev-core"
    error_message = "Expected service name output to match input service_name."
  }

  assert {
    condition     = output.log_group_name == "/aws/ecs/onemail-dev-core/core"
    error_message = "Expected log group output to follow /aws/ecs/<service>/<container>."
  }
}
