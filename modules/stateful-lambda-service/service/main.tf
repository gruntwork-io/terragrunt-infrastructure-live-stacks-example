# ---------------------------------------------------------------------------------------------------------------------
# LAMBDA FUNCTION OF THE STATEFUL LAMBDA SERVICE
# This module replaces the `units/js-lambda-stateful-service` Terragrunt unit of the catalog. It also contains the
# `iam_role_arn` and `environment_variables` inputs that the catalog's example stack sets in its `autoinclude` block.
# The root modules under `<account>/<region>/stateful-lambda-service/service` call it.
#
# The handler source is in `src/`. The Terragrunt unit packaged it with a `before_hook`. Here, a `run` step in
# `.stategraph/config.yml` runs `scripts/package-lambda.py` before each plan and apply, and writes `zip_file`.
#
# DEMO STAND-IN: this module does not create a Lambda function. A `terraform_data` resource keeps the function
# settings and the hash of `zip_file` in the state, and the outputs have the same shape as the outputs of a real
# function. A change to the handler source changes the hash, and thus shows in the plan, as it does for a real
# function. The repository plans and applies without AWS credentials and without network access to a provider
# registry.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.7"
}

resource "terraform_data" "function" {
  input = {
    name             = var.name
    arn              = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.name}"
    function_url     = "https://${var.name}.lambda-url.${var.aws_region}.on.aws/"
    runtime          = var.runtime
    handler          = var.handler
    memory           = var.memory
    timeout          = var.timeout
    iam_role_arn     = var.iam_role_arn
    source_code_hash = filebase64sha256(var.zip_file)

    environment_variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
    }
  }
}
