mock_provider "aws" {}

run "plan_with_derived_repository_names" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    repository_name_prefix = "onemail-dev"

    repositories = {
      core = {
        number_of_images_to_keep        = 30
        repository_image_tag_mutability = "IMMUTABLE"
      }
      internal_idp = {
        number_of_images_to_keep        = 30
        repository_image_tag_mutability = "IMMUTABLE"
      }
    }
  }

  assert {
    condition     = output.repository_names["core"] == "onemail-dev-core"
    error_message = "Expected core repository name to be derived from prefix and key."
  }

  assert {
    condition     = output.repository_names["internal_idp"] == "onemail-dev-internal-idp"
    error_message = "Expected internal_idp repository name to be derived from prefix and key."
  }
}

run "plan_with_name_override" {
  command = plan

  module {
    source = "./"
  }

  variables {
    product_name       = "onemail"
    env                = "dev"
    idvh_resource_tier = "standard"

    repository_name_prefix = "onemail-dev"

    repositories = {
      core = {
        number_of_images_to_keep        = 30
        repository_image_tag_mutability = "IMMUTABLE"
      }
    }

    repository_name_overrides = {
      core = "custom-core"
    }
  }

  assert {
    condition     = output.repository_names["core"] == "custom-core"
    error_message = "Expected repository_name_overrides to take precedence over derived names."
  }
}
