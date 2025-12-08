# ---------------------------------------------------------------------------------------------------------------------
# LAMBDA SERVICE
# This Terragrunt configuration deploys an AWS Lambda function using the lambda-service module
# from the Gruntwork Infrastructure Catalog Example.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # You'll typically want to pin this to a particular version of your catalog repo.
  # e.g.
  # source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/lambda-service?ref=v0.1.0"
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/lambda-service?ref=v1.0.0"

  # Zip the Lambda source code before running Terraform commands
  before_hook "zip_lambda_source" {
    commands = ["apply", "plan"]
    execute  = ["bash", "-c", "cd ${get_terragrunt_dir()}/src && zip -r ../lambda.zip ."]
  }
}

# Include the root `root.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE INPUTS
# These are the variables we pass to the lambda-service module.
# See https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example/tree/main/modules/lambda-service
# for all available options.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  # Required: The name of the Lambda function
  name = "example-lambda3-non-prod"

  # Required: The runtime environment for the Lambda function
  runtime = "python3.14"

  # Required: The function entrypoint in your code (file.function_name format)
  handler = "app.handler"

  # Required: Path to the zipped Lambda function code (created by before_hook)
  zip_file = "${get_terragrunt_dir()}/lambda.zip"

  # Required: Memory size in MB (128-10240)
  memory_size = 128

  # Required: Timeout in seconds (1-900)
  timeout = 30

  # Tags to apply to the Lambda function
  tags = {
    Environment = "non-prod"
    ManagedBy   = "terragrunt"
  }
}

