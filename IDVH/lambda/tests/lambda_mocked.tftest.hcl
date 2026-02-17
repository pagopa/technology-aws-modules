mock_provider "aws" {
  mock_data "aws_partition" {
    defaults = {
      id                 = "aws"
      partition          = "aws"
      dns_suffix         = "amazonaws.com"
      reverse_dns_prefix = "com.amazonaws"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_data "aws_iam_policy" {
    defaults = {
      arn    = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
      policy = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

override_data {
  target = data.aws_caller_identity.current
  values = {
    account_id = "123456789012"
    arn        = "arn:aws:iam::123456789012:user/mock"
    id         = "AIDAMOCKUSER"
    user_id    = "AIDAMOCKUSER"
  }
}

run "plan_with_mocked_aws_and_external_bucket" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name      = "onemail"
    env               = "dev"
    idvh_resource_tier = "standard_external_code_bucket"

    name         = "onemail-dev-lambda-test"
    package_path = "./tests/test_lambda_packages/test.zip"

    existing_code_bucket_name = "external-code-bucket"
    existing_code_bucket_arn  = "arn:aws:s3:::external-code-bucket"

    vpc_subnet_ids         = ["subnet-0123456789abcdef0"]
    vpc_security_group_ids = ["sg-0123456789abcdef0"]
  }

  assert {
    condition     = output.code_bucket_name == "external-code-bucket"
    error_message = "Expected external code bucket name to be exposed in output."
  }

  assert {
    condition     = output.code_bucket_arn == "arn:aws:s3:::external-code-bucket"
    error_message = "Expected external code bucket ARN to be exposed in output."
  }

  assert {
    condition     = output.github_lambda_deploy_role_arn == null
    error_message = "Expected deploy role output to be null when github_repository is not set."
  }
}
