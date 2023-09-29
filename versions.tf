# terraform {
#   required_version = ">= 1.3.1"
#   required_providers {
#        github = {
#          source  = "integrations/github"
#          version = ">= 5.3.0"
#        }
#        azurerm = {
#          source  = "hashicorp/azurerm"
#          version = ">= 3.22.0"
#        }
#   }
# }

terraform {
  required_version = ">= 1.5.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.13.1"
    }
  }
}
