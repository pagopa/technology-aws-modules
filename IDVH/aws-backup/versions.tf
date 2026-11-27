terraform {
  required_version = ">= 1.14.3"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.72.0, < 6.0.0"
      configuration_aliases = [aws.dr]
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4.0, < 3.0.0"
    }
  }
}
