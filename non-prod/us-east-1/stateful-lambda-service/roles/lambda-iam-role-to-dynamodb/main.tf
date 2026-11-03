# ---------------------------------------------------------------------------------------------------------------------
# NON-PROD / US-EAST-1 / STATEFUL-LAMBDA-SERVICE / ROLES / LAMBDA-IAM-ROLE-TO-DYNAMODB
# This root module replaces the `role` unit of the Terragrunt stack file.
# The Terragrunt `dependency "dynamodb_table"` becomes:
#   - `depends_on: relative_dir:../../db` in `.stategraph/config.yml` (order), and
#   - the `terraform_remote_state` below (data).
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.7"

  # DEMO: the state is the file `terraform.tfstate` in this directory.
  backend "local" {}
}

locals {
  name = "${var.app_prefix}stateful-lambda-service-dev"
}

# The path is the local state file of the db root module.
data "terraform_remote_state" "dynamodb_table" {
  backend = "local"

  config = {
    path = "${path.module}/../../db/terraform.tfstate"
  }
}

module "role" {
  source = "../../../../../modules/stateful-lambda-service/role"

  name               = "${local.name}-role"
  dynamodb_table_arn = data.terraform_remote_state.dynamodb_table.outputs.arn

  aws_account_id = var.aws_account_id
}

output "name" {
  value = module.role.name
}

output "arn" {
  value = module.role.arn
}
