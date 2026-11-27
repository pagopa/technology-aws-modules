mock_provider "aws" {
  source = "../../../tests/mocks"
  mock_data "aws_region" {
    defaults = { name = "eu-south-1" }
  }
}

mock_provider "aws" {
  alias  = "dr"
  source = "../../../tests/mocks"
  mock_data "aws_region" {
    defaults = { name = "eu-central-1" }
  }
}

run "minimum_provider_composition" {
  command = apply
  assert {
    condition     = module.backup.dr_vault_arn != null && module.backup.coverage_lambda_function_arn != null && module.backup.sns_topic_arn != null
    error_message = "The minimum AWS and Archive providers must support the production wrapper composition."
  }
}
