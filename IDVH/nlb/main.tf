module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "nlb"
}

locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  effective_internal                         = var.internal != null ? var.internal : local.idvh_config.internal
  effective_cross_zone_enabled               = var.cross_zone_enabled != null ? var.cross_zone_enabled : local.idvh_config.cross_zone_enabled
  effective_dns_record_client_routing_policy = var.dns_record_client_routing_policy != null ? var.dns_record_client_routing_policy : local.idvh_config.dns_record_client_routing_policy
  effective_target_health_path               = var.target_health_path != null ? var.target_health_path : local.idvh_config.target_health_path
  effective_deregistration_delay             = var.deregistration_delay != null ? var.deregistration_delay : local.idvh_config.deregistration_delay
  effective_enable_deletion_protection       = var.enable_deletion_protection != null ? var.enable_deletion_protection : local.idvh_config.enable_deletion_protection
  effective_target_group_name_prefix         = var.target_group_name_prefix != null ? var.target_group_name_prefix : try(local.idvh_config.target_group_name_prefix, "t1-")
  effective_core_container_port              = var.core_container_port != null ? var.core_container_port : local.idvh_config.core_container_port

  listeners = merge(
    {
      ecs_core = {
        port     = local.effective_core_container_port
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
        name_prefix          = local.effective_target_group_name_prefix
        protocol             = "TCP"
        port                 = local.effective_core_container_port
        target_type          = "ip"
        deregistration_delay = local.effective_deregistration_delay
        create_attachment    = false
        health_check = {
          enabled             = true
          interval            = 30
          path                = local.effective_target_health_path
          port                = local.effective_core_container_port
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
  enable_cross_zone_load_balancing = local.effective_cross_zone_enabled

  internal                         = local.effective_internal
  dns_record_client_routing_policy = local.effective_dns_record_client_routing_policy
  enable_deletion_protection       = local.effective_enable_deletion_protection

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
