terraform {
  required_version = ">= 1.14.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.72.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "= 2.4.0"
    }
  }
}

provider "aws" {
  region = "eu-south-1"
}

provider "aws" {
  alias  = "dr"
  region = "eu-central-1"
}

module "backup" {
  source = "../../.."
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  product_name                    = "aws-backup"
  env                             = "prod"
  aws_region                      = "eu-south-1"
  solution_prefix                 = "test-idvh-consumer"
  selection_tags                  = { backup-workload = "test-consumer" }
  coverage_expected_resource_tags = { backup-workload = "test-consumer" }
  email_endpoints                 = ["backup@example.com"]
}
