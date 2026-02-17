module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "ecs"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  effective_event_mode = var.event_mode != null ? var.event_mode : local.idvh_config.event_mode

  effective_internal_idp_enabled = var.internal_idp_enabled != null ? var.internal_idp_enabled : local.idvh_config.internal_idp_enabled

  effective_ecs_cluster_name = var.ecs_cluster_name != null ? var.ecs_cluster_name : local.idvh_config.ecs_cluster_name

  effective_nlb_name = var.nlb_name != null ? var.nlb_name : local.idvh_config.nlb.name

  core_effective_autoscaling = (
    local.effective_event_mode && local.idvh_config.service_core.event_autoscaling != null
    ? local.idvh_config.service_core.event_autoscaling
    : local.idvh_config.service_core.autoscaling
  )

  ecr_registers_by_name = { for register in local.idvh_config.ecr_registers : register.name => register }

  core_environment = concat(local.idvh_config.service_core.environment_variables, var.service_core_environment_variables)

  internal_idp_environment = concat(local.idvh_config.service_internal_idp.environment_variables, var.service_internal_idp_environment_variables)

  github_deploy_role_enabled = local.idvh_config.deploy_role.enabled && var.github_repository != null

  effective_service_internal_idp_image_version = var.service_internal_idp_image_version != null ? var.service_internal_idp_image_version : "not-used"
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "1.6.0"

  for_each = local.ecr_registers_by_name

  repository_name = each.key

  repository_read_write_access_arns = []

  repository_image_tag_mutability = each.value.repository_image_tag_mutability

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last ${each.value.number_of_images_to_keep} images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = each.value.number_of_images_to_keep,
        },
        action = {
          type = "expire",
        },
      },
    ],
  })

  create_registry_replication_configuration = false
  registry_replication_rules                = []

  tags = merge(
    var.tags,
    {
      Name = each.key
    }
  )
}

module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.9.1"

  cluster_name = local.effective_ecs_cluster_name

  cluster_settings = [
    {
      name  = "containerInsights"
      value = local.idvh_config.enable_container_insights ? "enabled" : "disabled"
    },
  ]

  fargate_capacity_providers = local.idvh_config.fargate_capacity_providers

  tags = merge(
    var.tags,
    {
      Name = local.effective_ecs_cluster_name
    }
  )
}

module "elb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.8.0"

  name               = local.effective_nlb_name
  load_balancer_type = "network"

  vpc_id                           = var.vpc_id
  subnets                          = var.private_subnets
  enable_cross_zone_load_balancing = local.idvh_config.nlb.cross_zone_enabled

  internal = local.idvh_config.nlb.internal

  dns_record_client_routing_policy = local.idvh_config.nlb.dns_record_client_routing_policy

  enable_deletion_protection = local.idvh_config.nlb.enable_deletion_protection

  enforce_security_group_inbound_rules_on_private_link_traffic = "off"

  security_group_ingress_rules = {}

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = var.vpc_cidr_block
    }
  }

  listeners = merge(
    {
      "ecs-core" = {
        port     = local.idvh_config.service_core.container.container_port
        protocol = "TCP"
        forward = {
          target_group_key = "ecs-core"
        }
      }
    },
    local.effective_internal_idp_enabled ? {
      "ecs-internal-idp" = {
        port     = local.idvh_config.service_internal_idp.container.container_port
        protocol = "TCP"
        forward = {
          target_group_key = "ecs-internal-idp"
        }
      }
    } : {}
  )

  target_groups = merge(
    {
      "ecs-core" = {
        name_prefix          = "t1-"
        protocol             = "TCP"
        port                 = local.idvh_config.service_core.container.container_port
        target_type          = "ip"
        deregistration_delay = local.idvh_config.nlb.deregistration_delay
        create_attachment    = false
        health_check = {
          enabled             = true
          interval            = 30
          path                = local.idvh_config.nlb.target_health_path
          port                = local.idvh_config.service_core.container.container_port
          healthy_threshold   = 3
          unhealthy_threshold = 3
          timeout             = 6
        }
      }
    },
    local.effective_internal_idp_enabled ? {
      "ecs-internal-idp" = {
        name_prefix          = "t1-"
        protocol             = "TCP"
        port                 = local.idvh_config.service_internal_idp.container.container_port
        target_type          = "ip"
        deregistration_delay = local.idvh_config.nlb.deregistration_delay
        create_attachment    = false
        health_check = {
          enabled             = true
          interval            = 30
          path                = local.idvh_config.nlb.target_health_path
          port                = local.idvh_config.service_internal_idp.container.container_port
          healthy_threshold   = 3
          unhealthy_threshold = 3
          timeout             = 6
        }
      }
    } : {}
  )

  tags = merge(
    var.tags,
    {
      Name = local.effective_nlb_name
    }
  )
}

resource "aws_cloudwatch_log_group" "ecs_core" {
  name = format("/aws/ecs/%s/%s", local.idvh_config.service_core.service_name, local.idvh_config.service_core.container.name)

  retention_in_days = local.idvh_config.service_core.container.logs_retention_days

  tags = merge(
    var.tags,
    {
      Name = format("/aws/ecs/%s/%s", local.idvh_config.service_core.service_name, local.idvh_config.service_core.container.name)
    }
  )
}

resource "aws_iam_policy" "ecs_core_task" {
  count = var.service_core_task_policy_json != null ? 1 : 0

  name   = format("%s-task-policy", local.idvh_config.service_core.service_name)
  policy = var.service_core_task_policy_json
}

module "ecs_core_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.9.1"

  name = local.idvh_config.service_core.service_name

  cluster_arn = module.ecs_cluster.cluster_arn

  cpu    = local.idvh_config.service_core.cpu
  memory = local.idvh_config.service_core.memory

  enable_execute_command = local.idvh_config.service_core.enable_execute_command

  tasks_iam_role_policies = var.service_core_task_policy_json != null ? {
    ecs_core_task = aws_iam_policy.ecs_core_task[0].arn
  } : {}

  container_definitions = {
    (local.idvh_config.service_core.container.name) = {
      cpu                         = local.idvh_config.service_core.container.cpu
      memory                      = local.idvh_config.service_core.memory
      create_cloudwatch_log_group = false

      essential = true
      image     = "${module.ecr[local.idvh_config.service_core.container.image_name].repository_url}:${var.service_core_image_version}"

      port_mappings = [
        {
          name          = local.idvh_config.service_core.container.name
          containerPort = local.idvh_config.service_core.container.container_port
          hostPort      = local.idvh_config.service_core.container.host_port
          protocol      = "tcp"
        },
      ]

      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_core.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
          mode                  = "non-blocking"
        }
      }

      environment = local.core_environment

      readonly_root_filesystem = false
    }
  }

  enable_autoscaling       = local.idvh_config.service_core.autoscaling.enable
  autoscaling_min_capacity = local.core_effective_autoscaling.min_capacity
  autoscaling_max_capacity = local.core_effective_autoscaling.max_capacity
  desired_count            = local.core_effective_autoscaling.desired_count

  autoscaling_policies = {
    cpu = {
      policy_type = "TargetTrackingScaling",
      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
        disable_scale_in = true
      }
    },
    memory = {
      policy_type = "TargetTrackingScaling",
      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
        disable_scale_in = true
      }
    },
    cpu_high = {
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type = "ChangeInCapacity"
        step_adjustment = [
          {
            scaling_adjustment          = local.idvh_config.service_core.cpu_high_scaling_adjustment
            metric_interval_lower_bound = 0
          },
        ]
        cooldown = 60
      }
    },
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
    },
  }

  subnet_ids       = var.private_subnets
  assign_public_ip = false

  load_balancer = {
    service = {
      target_group_arn = module.elb.target_groups["ecs-core"].arn
      container_name   = local.idvh_config.service_core.container.name
      container_port   = local.idvh_config.service_core.container.container_port
    }
  }

  security_group_rules = {
    nlb_ingress = {
      type                     = "ingress"
      from_port                = local.idvh_config.service_core.container.container_port
      to_port                  = local.idvh_config.service_core.container.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.elb.security_group_id
    },
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
  }

  tags = merge(
    var.tags,
    {
      Name = local.idvh_config.service_core.service_name
    }
  )
}

resource "aws_cloudwatch_log_group" "ecs_internal_idp" {
  count = local.effective_internal_idp_enabled ? 1 : 0

  name = format("/aws/ecs/%s/%s", local.idvh_config.service_internal_idp.service_name, local.idvh_config.service_internal_idp.container.name)

  retention_in_days = local.idvh_config.service_internal_idp.container.logs_retention_days

  tags = merge(
    var.tags,
    {
      Name = format("/aws/ecs/%s/%s", local.idvh_config.service_internal_idp.service_name, local.idvh_config.service_internal_idp.container.name)
    }
  )
}

resource "aws_iam_policy" "ecs_internal_idp_task" {
  count = local.effective_internal_idp_enabled && var.service_internal_idp_task_policy_json != null ? 1 : 0

  name   = format("%s-task-policy", local.idvh_config.service_internal_idp.service_name)
  policy = var.service_internal_idp_task_policy_json
}

module "ecs_internal_idp_service" {
  count   = local.effective_internal_idp_enabled ? 1 : 0
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.9.1"

  name = local.idvh_config.service_internal_idp.service_name

  cluster_arn = module.ecs_cluster.cluster_arn

  cpu    = local.idvh_config.service_internal_idp.cpu
  memory = local.idvh_config.service_internal_idp.memory

  enable_execute_command = local.idvh_config.service_internal_idp.enable_execute_command

  tasks_iam_role_policies = local.effective_internal_idp_enabled && var.service_internal_idp_task_policy_json != null ? {
    ecs_internal_idp_task = aws_iam_policy.ecs_internal_idp_task[0].arn
  } : {}

  container_definitions = {
    (local.idvh_config.service_internal_idp.container.name) = {
      cpu                         = local.idvh_config.service_internal_idp.container.cpu
      memory                      = local.idvh_config.service_internal_idp.memory
      create_cloudwatch_log_group = false

      essential = true
      image     = "${module.ecr[local.idvh_config.service_internal_idp.container.image_name].repository_url}:${local.effective_service_internal_idp_image_version}"

      port_mappings = [
        {
          name          = local.idvh_config.service_internal_idp.container.name
          containerPort = local.idvh_config.service_internal_idp.container.container_port
          hostPort      = local.idvh_config.service_internal_idp.container.host_port
          protocol      = "tcp"
        },
      ]

      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_internal_idp[0].name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
          mode                  = "non-blocking"
        }
      }

      environment = local.internal_idp_environment

      readonly_root_filesystem = false
    }
  }

  enable_autoscaling       = local.idvh_config.service_internal_idp.autoscaling.enable
  autoscaling_min_capacity = local.idvh_config.service_internal_idp.autoscaling.min_capacity
  autoscaling_max_capacity = local.idvh_config.service_internal_idp.autoscaling.max_capacity
  desired_count            = local.idvh_config.service_internal_idp.autoscaling.desired_count

  subnet_ids       = var.private_subnets
  assign_public_ip = false

  load_balancer = {
    service = {
      target_group_arn = module.elb.target_groups["ecs-internal-idp"].arn
      container_name   = local.idvh_config.service_internal_idp.container.name
      container_port   = local.idvh_config.service_internal_idp.container.container_port
    }
  }

  security_group_rules = {
    nlb_ingress = {
      type                     = "ingress"
      from_port                = local.idvh_config.service_internal_idp.container.container_port
      to_port                  = local.idvh_config.service_internal_idp.container.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.elb.security_group_id
    },
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
  }

  tags = merge(
    var.tags,
    {
      Name = local.idvh_config.service_internal_idp.service_name
    }
  )
}

resource "aws_iam_role" "githubecsdeploy" {
  count = local.github_deploy_role_enabled ? 1 : 0

  name        = "${local.idvh_config.service_core.service_name}-deploy-ecs"
  description = "Role to deploy ECS service with GitHub Actions."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:*"
          }
          "ForAllValues:StringEquals" = {
            "token.actions.githubusercontent.com:iss" = "https://token.actions.githubusercontent.com"
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "deploy_ecs" {
  count = local.github_deploy_role_enabled ? 1 : 0

  name        = "${local.idvh_config.service_core.service_name}-deploy-ecs"
  description = "Policy to allow GitHub Actions deployments on ECS core service."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECRPublish"
        Effect   = "Allow"
        Action   = local.idvh_config.deploy_role.ecr_actions
        Resource = ["*"]
      },
      {
        Sid      = "ECSTaskDefinition"
        Effect   = "Allow"
        Action   = local.idvh_config.deploy_role.ecs_actions
        Resource = "*"
      },
      {
        Sid    = "PassRole"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          module.ecs_core_service.tasks_iam_role_arn,
          module.ecs_core_service.task_exec_iam_role_arn,
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "deploy_ecs" {
  count = local.github_deploy_role_enabled ? 1 : 0

  role       = aws_iam_role.githubecsdeploy[0].name
  policy_arn = aws_iam_policy.deploy_ecs[0].arn
}

resource "aws_iam_role" "githubecsdeploy_internal_idp" {
  count = local.github_deploy_role_enabled && local.effective_internal_idp_enabled ? 1 : 0

  name        = "${local.idvh_config.service_internal_idp.service_name}-deploy-ecs"
  description = "Role to deploy ECS internal IDP service with GitHub Actions."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:*"
          }
          "ForAllValues:StringEquals" = {
            "token.actions.githubusercontent.com:iss" = "https://token.actions.githubusercontent.com"
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "deploy_ecs_internal_idp" {
  count = local.github_deploy_role_enabled && local.effective_internal_idp_enabled ? 1 : 0

  name        = "${local.idvh_config.service_internal_idp.service_name}-deploy-ecs"
  description = "Policy to allow GitHub Actions deployments on ECS internal IDP service."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECRPublish"
        Effect   = "Allow"
        Action   = local.idvh_config.deploy_role.ecr_actions
        Resource = ["*"]
      },
      {
        Sid      = "ECSTaskDefinition"
        Effect   = "Allow"
        Action   = local.idvh_config.deploy_role.ecs_actions
        Resource = "*"
      },
      {
        Sid    = "PassRole"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          module.ecs_internal_idp_service[0].tasks_iam_role_arn,
          module.ecs_internal_idp_service[0].task_exec_iam_role_arn,
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "deploy_ecs_internal_idp" {
  count = local.github_deploy_role_enabled && local.effective_internal_idp_enabled ? 1 : 0

  role       = aws_iam_role.githubecsdeploy_internal_idp[0].name
  policy_arn = aws_iam_policy.deploy_ecs_internal_idp[0].arn
}
