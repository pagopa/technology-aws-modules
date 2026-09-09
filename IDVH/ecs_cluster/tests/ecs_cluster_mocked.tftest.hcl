mock_provider "aws" {}

run "plan_with_default_capacity_provider" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    cluster_name              = "onemail-dev-ecs-cluster"
    enable_container_insights = true

    default_capacity_provider_strategy = {
      FARGATE = {
        weight = 100
        base   = 1
      }
    }
  }

  assert {
    condition     = output.cluster_name == "onemail-dev-ecs-cluster"
    error_message = "Expected cluster_name output to match input cluster_name."
  }
}
