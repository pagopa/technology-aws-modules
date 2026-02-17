data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "service" {
  name = "/aws/ecs/${var.service_name}/${var.container_name}"

  retention_in_days = var.logs_retention_days

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

module "service_raw" {
  # Release URL: https://github.com/terraform-aws-modules/terraform-aws-ecs/releases/tag/v5.9.1
  # Pinned commit: https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/45f532c06488d84f140af36241d164facb5e05f5
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git//modules/service?ref=45f532c06488d84f140af36241d164facb5e05f5"

  name        = var.service_name
  cluster_arn = var.cluster_arn

  cpu    = var.cpu
  memory = var.memory

  enable_execute_command = var.enable_execute_command

  tasks_iam_role_policies = var.task_policy_json != null ? {
    task = aws_iam_policy.task[0].arn
  } : {}

  container_definitions = {
    (var.container_name) = {
      cpu                         = var.container_cpu
      memory                      = var.memory
      create_cloudwatch_log_group = false

      essential = true
      image     = var.image

      port_mappings = [
        {
          name          = var.container_name
          containerPort = var.container_port
          hostPort      = var.host_port
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

      environment = var.environment_variables

      readonly_root_filesystem = false
    }
  }

  enable_autoscaling       = var.autoscaling.enable
  autoscaling_min_capacity = var.autoscaling.min_capacity
  autoscaling_max_capacity = var.autoscaling.max_capacity
  desired_count            = var.autoscaling.desired_count

  autoscaling_policies = var.autoscaling_policies

  subnet_ids       = var.private_subnets
  assign_public_ip = false

  load_balancer = {
    service = {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  security_group_rules = {
    nlb_ingress = {
      type                     = "ingress"
      from_port                = var.container_port
      to_port                  = var.container_port
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
