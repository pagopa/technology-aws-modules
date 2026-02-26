locals {
  listeners = merge(
    {
      ecs_core = {
        port     = var.core_container_port
        protocol = "TCP"
        forward = {
          target_group_key = "ecs_core"
        }
      }
    }
  )

  target_groups = merge(
    {
      ecs_core = {
        name_prefix          = var.target_group_name_prefix
        protocol             = "TCP"
        port                 = var.core_container_port
        target_type          = "ip"
        deregistration_delay = var.deregistration_delay
        create_attachment    = false
        health_check = {
          enabled             = true
          interval            = 30
          path                = var.target_health_path
          port                = var.core_container_port
          healthy_threshold   = 3
          unhealthy_threshold = 3
          timeout             = 6
        }
      }
    }
  )
}

module "nlb_raw" {
  # Release URL: https://github.com/terraform-aws-modules/terraform-aws-alb/releases/tag/v9.8.0
  # Pinned commit: https://github.com/terraform-aws-modules/terraform-aws-alb/commit/eb15097ece19399858ae84518bb900bd34494a74
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git?ref=eb15097ece19399858ae84518bb900bd34494a74"

  name               = var.name
  load_balancer_type = "network"

  vpc_id                           = var.vpc_id
  subnets                          = var.private_subnets
  enable_cross_zone_load_balancing = var.cross_zone_enabled

  internal                         = var.internal
  dns_record_client_routing_policy = var.dns_record_client_routing_policy
  enable_deletion_protection       = var.enable_deletion_protection

  enforce_security_group_inbound_rules_on_private_link_traffic = "off"

  security_group_ingress_rules = {}

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = var.vpc_cidr_block
    }
  }

  listeners     = local.listeners
  target_groups = local.target_groups

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
