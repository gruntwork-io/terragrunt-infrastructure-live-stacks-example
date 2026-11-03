# ---------------------------------------------------------------------------------------------------------------------
# IAM ROLE THAT LETS THE LAMBDA FUNCTION USE THE DYNAMODB TABLE
# This module replaces the `units/lambda-iam-role-to-dynamodb` Terragrunt unit of the catalog. It also contains the
# `policy` input that the catalog's example stack sets in its `autoinclude` block. The root modules under
# `<account>/<region>/stateful-lambda-service/roles/lambda-iam-role-to-dynamodb` call it.
#
# DEMO STAND-IN: this module does not create an IAM role. A `terraform_data` resource keeps the role name and the
# policy documents in the state, and the outputs have the same shape as the outputs of a real role. Thus the
# repository plans and applies without AWS credentials and without network access to a provider registry.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.7"
}

resource "terraform_data" "role" {
  input = {
    name = var.name
    arn  = "arn:aws:iam::${var.aws_account_id}:role/${var.name}"

    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        }
      ]
    })

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:logs:*:*:*"
        },
        {
          Action = [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem"
          ]
          Effect   = "Allow"
          Resource = var.dynamodb_table_arn
        }
      ]
    })
  }
}
