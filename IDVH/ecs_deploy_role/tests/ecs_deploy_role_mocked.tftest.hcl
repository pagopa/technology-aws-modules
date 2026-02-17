mock_provider "aws" {}

override_data {
  target = data.aws_caller_identity.current
  values = {
    account_id = "123456789012"
    arn        = "arn:aws:iam::123456789012:user/mock"
    id         = "AIDAMOCKUSER"
    user_id    = "AIDAMOCKUSER"
  }
}

run "plan_without_github_repository" {
  command = plan

  module {
    source = "./"
  }

  variables {
    enabled           = true
    service_name      = "onemail-dev-core"
    github_repository = null

    ecr_actions = [
      "ecr:BatchGetImage",
      "ecr:PutImage",
    ]

    ecs_actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService",
    ]

    pass_role_arns = [
      "arn:aws:iam::123456789012:role/mock-task-role",
      "arn:aws:iam::123456789012:role/mock-task-exec-role",
    ]
  }

  assert {
    condition     = output.role_arn == null
    error_message = "Expected role_arn output to be null when github_repository is not provided."
  }
}
