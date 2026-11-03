# ---------------------------------------------------------------------------------------------------------------------
# DYNAMODB TABLE FOR THE STATEFUL LAMBDA SERVICE
# This module replaces the `units/dynamodb-table` Terragrunt unit of the catalog. The root modules under
# `<account>/<region>/stateful-lambda-service/db` call it.
#
# DEMO STAND-IN: this module does not create a DynamoDB table. A `terraform_data` resource keeps the table settings
# in the state, and the outputs have the same shape as the outputs of a real table. Thus the repository plans and
# applies without AWS credentials and without network access to a provider registry.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.7"
}

resource "terraform_data" "table" {
  input = {
    name          = var.name
    hash_key      = var.hash_key
    hash_key_type = var.hash_key_type
    billing_mode  = var.billing_mode
    arn           = "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.name}"
  }
}
