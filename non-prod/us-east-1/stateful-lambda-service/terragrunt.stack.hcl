locals {
  name = "${get_env("EX_APP_PREFIX", "")}stateful-lambda-service-dev"
}

unit "lambda_service" {
  // You'll typically want to pin this to a particular version of your catalog repo.
  // e.g.
  // source = "github.com/acme/terragrunt-infrastructure-catalog//units/lambda-stateful-service?ref=v0.1.0"
  //
  // If you are using a private catalog, you may want to use an SSH source URL instead:
  // source = "git::git@github.com:acme/terragrunt-infrastructure-catalog.git//units/lambda-stateful-service"
  source = "github.com/gruntwork-io/terragrunt-infrastructure-catalog-example//units/js-lambda-stateful-service"

  path = "service"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    name = local.name

    // Required inputs
    runtime    = "nodejs22.x"
    source_dir = "./src"
    handler    = "index.handler"
    zip_file   = "handler.zip"

    // Optional inputs
    memory  = 128
    timeout = 3

    // Dependency paths
    role_path           = "../roles/lambda-iam-role-to-dynamodb"
    dynamodb_table_path = "../db"
  }
}

unit "db" {
  // You'll typically want to pin this to a particular version of your catalog repo.
  // e.g.
  // source = "github.com/acme/terragrunt-infrastructure-catalog//units/dynamodb-table?ref=v0.1.0"
  //
  // If you are using a private catalog, you may want to use an SSH source URL instead:
  // source = "git::git@github.com:acme/terragrunt-infrastructure-catalog.git//units/dynamodb-table"
  source = "github.com/gruntwork-io/terragrunt-infrastructure-catalog-example//units/dynamodb-table"

  path = "db"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    name          = "${local.name}-db"
    hash_key      = "Id"
    hash_key_type = "S"
  }
}

unit "role" {
  // You'll typically want to pin this to a particular version of your catalog repo.
  // e.g.
  // source = "github.com/acme/terragrunt-infrastructure-catalog//units/lambda-iam-role-to-dynamodb?ref=v0.1.0"
  //
  // If you are using a private catalog, you may want to use an SSH source URL instead:
  // source = "git::git@github.com:acme/terragrunt-infrastructure-catalog.git//units/lambda-iam-role-to-dynamodb"
  source = "github.com/gruntwork-io/terragrunt-infrastructure-catalog-example//units/lambda-iam-role-to-dynamodb"

  path = "roles/lambda-iam-role-to-dynamodb"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    name = "${local.name}-role"

    dynamodb_table_path = "../../db"
  }
}
