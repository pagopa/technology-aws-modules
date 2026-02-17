mock_provider "aws" {}

run "plan_with_fargate_capacity_provider" {
  command = plan

  module {
    source = "./"
  }

  variables {
    cluster_name              = "onemail-dev-ecs-cluster"
    enable_container_insights = true

    fargate_capacity_providers = {
      FARGATE = {
        default_capacity_provider_strategy = {
          weight = 100
          base   = 1
        }
      }
    }
  }

  assert {
    condition     = output.cluster_name == "onemail-dev-ecs-cluster"
    error_message = "Expected cluster_name output to match input cluster_name."
  }
}
