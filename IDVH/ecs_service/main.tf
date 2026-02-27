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

  effective_autoscaling = (
    local.effective_event_mode && local.idvh_config.event_autoscaling != null
    ? local.idvh_config.event_autoscaling
    : local.idvh_config.autoscaling
  )

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
  # Release URL: https://github.com/terraform-aws-modules/terraform-aws-ecs/releases/tag/v5.9.1
  # Pinned commit: https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/45f532c06488d84f140af36241d164facb5e05f5
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git//modules/service?ref=45f532c06488d84f140af36241d164facb5e05f5"

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

  enable_autoscaling       = local.idvh_config.autoscaling.enable
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

  security_group_rules = {
    nlb_ingress = {
      type                     = "ingress"
      from_port                = local.idvh_config.container.container_port
      to_port                  = local.idvh_config.container.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = var.nlb_security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.service_name
    }
  )
}
