# ---------------------------------------------------------------------------------------------------------------------
# NON-PROD / US-EAST-1 / STATEFUL-LAMBDA-SERVICE / DB
# This root module replaces the `db` unit of the Terragrunt stack file.
# Stategraph Orchestration sets the account and region variables from the `non-prod` stack in `.stategraph/config.yml`.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.7"

  # DEMO: the state is the file `terraform.tfstate` in this directory.
  backend "local" {}
}

locals {
  name = "${var.app_prefix}stateful-lambda-service-dev"
}

module "db" {
  source = "../../../../modules/stateful-lambda-service/db"

  name          = "${local.name}-db"
  hash_key      = "Id"
  hash_key_type = "S"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
}

output "name" {
  value = module.db.name
}

output "arn" {
  value = module.db.arn
}
