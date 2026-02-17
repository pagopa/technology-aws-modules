mock_provider "aws" {}

run "plan_without_internal_idp_listener" {
  command = plan

  module {
    source = "./"
  }

  variables {
    name            = "onemail-dev-nlb"
    vpc_id          = "vpc-0123456789abcdef0"
    private_subnets = ["subnet-0123456789abcdef0"]
    vpc_cidr_block  = "10.0.0.0/16"

    core_container_port         = 8080
    internal_idp_enabled        = false
    internal_idp_container_port = null

    internal                         = true
    cross_zone_enabled               = true
    dns_record_client_routing_policy = "availability_zone_affinity"
    target_health_path               = "/q/health/live"
    deregistration_delay             = 10
    enable_deletion_protection       = false
  }

  assert {
    condition     = contains(keys(output.target_groups), "ecs_core")
    error_message = "Expected core target group to be present."
  }

  assert {
    condition     = length(keys(output.target_groups)) == 1
    error_message = "Expected only one target group when internal_idp_enabled is false."
  }
}

run "plan_with_internal_idp_listener" {
  command = plan

  module {
    source = "./"
  }

  variables {
    name            = "onemail-uat-nlb"
    vpc_id          = "vpc-0123456789abcdef0"
    private_subnets = ["subnet-0123456789abcdef0"]
    vpc_cidr_block  = "10.0.0.0/16"

    core_container_port         = 8080
    internal_idp_enabled        = true
    internal_idp_container_port = 8082

    internal                         = true
    cross_zone_enabled               = true
    dns_record_client_routing_policy = "availability_zone_affinity"
    target_health_path               = "/q/health/live"
    deregistration_delay             = 10
    enable_deletion_protection       = false
  }

  assert {
    condition     = contains(keys(output.target_groups), "ecs_internal_idp")
    error_message = "Expected internal_idp target group to be present when internal_idp_enabled is true."
  }
}
