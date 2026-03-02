module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "ecs_service"
}

data "aws_region" "current" {}

locals {
  effective_event_mode = var.event_mode != null ? var.event_mode : local.idvh_config.event_mode

  effective_autoscaling = {
    enable        = local.idvh_config.autoscaling.enable
    desired_count = (local.effective_event_mode && local.idvh_config.event_autoscaling != null) ? local.idvh_config.event_autoscaling.desired_count : local.idvh_config.autoscaling.desired_count
    min_capacity  = (local.effective_event_mode && local.idvh_config.event_autoscaling != null) ? local.idvh_config.event_autoscaling.min_capacity : local.idvh_config.autoscaling.min_capacity
    max_capacity  = (local.effective_event_mode && local.idvh_config.event_autoscaling != null) ? local.idvh_config.event_autoscaling.max_capacity : local.idvh_config.autoscaling.max_capacity
  }

  effective_environment_variables = concat(local.idvh_config.environment_variables, var.environment_variables)
}

resource "aws_cloudwatch_log_group" "service" {
  name = "/aws/ecs/${var.service_name}/${var.container_name}"

  retention_in_days = local.idvh_config.container.logs_retention_days

  tags = merge(
    var.tags,
    {
      Name = "/aws/ecs/${var.service_name}/${var.container_name}"
    }
  )
}

resource "aws_iam_policy" "task" {
  count = var.task_policy_json != null ? 1 : 0

  name   = "${var.service_name}-task-policy"
  policy = var.task_policy_json
}

module "ecs_service" {
  # Release URL: https://github.com/terraform-aws-modules/terraform-aws-ecs/releases/tag/v6.0.0
  # Pinned commit: https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/cfd967a4790b541b722ff94692588657b77d62ed
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git//modules/service?ref=cfd967a4790b541b722ff94692588657b77d62ed"

  name = var.service_name

  cluster_arn = var.cluster_arn

  cpu    = local.idvh_config.cpu
  memory = local.idvh_config.memory

  enable_execute_command = local.idvh_config.enable_execute_command

  tasks_iam_role_policies = var.task_policy_json != null ? {
    task_policy = aws_iam_policy.task[0].arn
  } : {}

  container_definitions = {
    (var.container_name) = {
      cpu                         = local.idvh_config.container.cpu
      memory                      = local.idvh_config.memory
      create_cloudwatch_log_group = false

      essential = true
      image     = var.image

      port_mappings = [
        {
          name          = var.container_name
          containerPort = local.idvh_config.container.container_port
          hostPort      = local.idvh_config.container.host_port
          protocol      = "tcp"
        },
      ]

      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.service.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
          mode                  = "non-blocking"
        }
      }

      environment = local.effective_environment_variables

      readonly_root_filesystem = false
    }
  }

  enable_autoscaling       = local.effective_autoscaling.enable
  autoscaling_min_capacity = local.effective_autoscaling.min_capacity
  autoscaling_max_capacity = local.effective_autoscaling.max_capacity
  desired_count            = local.effective_autoscaling.desired_count

  autoscaling_policies = {
    cpu = {
      policy_type = "TargetTrackingScaling"
      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
        disable_scale_in = true
      }
    }
    memory = {
      policy_type = "TargetTrackingScaling"
      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
        disable_scale_in = true
      }
    }
    cpu_high = {
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type = "ChangeInCapacity"
        step_adjustment = [
          {
            scaling_adjustment          = local.idvh_config.cpu_high_scaling_adjustment
            metric_interval_lower_bound = 0
          },
        ]
        cooldown = 60
      }
    }
    cpu_low = {
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type = "ChangeInCapacity"
        step_adjustment = [
          {
            scaling_adjustment          = -1
            metric_interval_lower_bound = 0
          },
        ]
        cooldown = 300
      }
    }
  }

  subnet_ids       = var.private_subnets
  assign_public_ip = false

  load_balancer = {
    service = {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name
      container_port   = local.idvh_config.container.container_port
    }
  }

  security_group_ingress_rules = {
    nlb_ingress = {
      description                  = "Service port"
      from_port                    = local.idvh_config.container.container_port
      to_port                      = local.idvh_config.container.container_port
      ip_protocol                  = "tcp"
      referenced_security_group_id = var.nlb_security_group_id
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.service_name
    }
  )
}
