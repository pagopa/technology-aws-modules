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
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    service_name      = "onemail-dev-core"
    github_repository = null

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

run "plan_with_catalog_standard_tier" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    service_name      = "onemail-dev-core"
    github_repository = "pagopa/onemail"

    pass_role_arns = [
      "arn:aws:iam::123456789012:role/mock-task-role",
      "arn:aws:iam::123456789012:role/mock-task-exec-role",
    ]
  }

  assert {
    condition     = output.role_arn != null
    error_message = "Expected role_arn output to be populated when the catalog enables the deploy role and github_repository is provided."
  }
}

run "fails_when_role_enabled_and_service_name_is_empty" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    service_name      = ""
    github_repository = "pagopa/onemail"

    pass_role_arns = [
      "arn:aws:iam::123456789012:role/mock-task-role",
      "arn:aws:iam::123456789012:role/mock-task-exec-role",
    ]
  }

  expect_failures = [
    check.ecs_deploy_role_dynamic_inputs,
  ]
}
