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

run "plan_with_mocked_aws" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard_external_code_bucket"

    name         = "onemail-dev-lambda-test"
    package_path = "./tests/test_lambda_packages/test.zip"

    vpc_subnet_ids         = ["subnet-0123456789abcdef0"]
    vpc_security_group_ids = ["sg-0123456789abcdef0"]
  }

  assert {
    condition     = output.lambda_function_name == "onemail-dev-lambda-test"
    error_message = "Expected lambda function name output to match the configured name."
  }

  assert {
    condition     = output.lambda_log_group_name == "/aws/lambda/onemail-dev-lambda-test"
    error_message = "Expected CloudWatch log group output to follow the lambda naming convention."
  }

  assert {
    condition     = output.github_lambda_deploy_role_arn == null
    error_message = "Expected deploy role output to be null because deploy role creation is outside this module."
  }
}

run "plan_with_explicit_policy_json_attachment" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    name         = "onemail-dev-lambda-policy-test"
    package_path = "./tests/test_lambda_packages/test.zip"

    attach_lambda_policy_json = true
    lambda_policy_json = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["xray:GetSamplingStatisticSummaries"]
          Resource = ["*"]
        }
      ]
    })
  }

  assert {
    condition     = output.lambda_function_name == "onemail-dev-lambda-policy-test"
    error_message = "Expected lambda function name output to match the configured name when explicit policy attachment is enabled."
  }
}
