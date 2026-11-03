# ---------------------------------------------------------------------------------------------------------------------
# NON-PROD / US-EAST-1 / STATEFUL-LAMBDA-SERVICE / SERVICE
# This root module replaces the `lambda_service` unit of the Terragrunt stack file.
# The Terragrunt `dependency "role"` and `dependency "dynamodb_table"` become:
#   - `depends_on` in `.stategraph/config.yml` (order), and
#   - the `terraform_remote_state` data sources below (data).
# A `run` step in `.stategraph/config.yml` writes `handler.zip` in this directory before each plan and apply.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.7"

  # DEMO: the state is the file `terraform.tfstate` in this directory.
  backend "local" {}
}

locals {
  name = "${var.app_prefix}stateful-lambda-service-dev"
}

# The paths are the local state files of those root modules.
data "terraform_remote_state" "role" {
  backend = "local"

  config = {
    path = "${path.module}/../roles/lambda-iam-role-to-dynamodb/terraform.tfstate"
  }
}

data "terraform_remote_state" "dynamodb_table" {
  backend = "local"

  config = {
    path = "${path.module}/../db/terraform.tfstate"
  }
}

module "lambda_service" {
  source = "../../../../modules/stateful-lambda-service/service"

  name     = local.name
  runtime  = "nodejs22.x"
  handler  = "index.handler"
  zip_file = "${path.module}/handler.zip"
  memory   = 128
  timeout  = 3

  iam_role_arn        = data.terraform_remote_state.role.outputs.arn
  dynamodb_table_name = data.terraform_remote_state.dynamodb_table.outputs.name

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
}

output "function_url" {
  value = module.lambda_service.function_url
}

output "function_arn" {
  value = module.lambda_service.function_arn
}

output "function_name" {
  value = module.lambda_service.function_name
}
