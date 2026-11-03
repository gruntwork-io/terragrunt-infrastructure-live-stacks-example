# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the Lambda function."
  type        = string
}

variable "runtime" {
  description = "The Lambda runtime, for example nodejs22.x."
  type        = string
}

variable "handler" {
  description = "The function entrypoint in the handler source, for example index.handler."
  type        = string
}

variable "zip_file" {
  description = "The path to the zip file of the handler source. It must exist when the plan and the apply run."
  type        = string
}

variable "iam_role_arn" {
  description = "The ARN of the IAM role that the Lambda function uses."
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table. The function reads it from the DYNAMODB_TABLE environment variable."
  type        = string
}

variable "aws_account_id" {
  description = "The ID of the AWS account. The module uses it only to make the ARN."
  type        = string
}

variable "aws_region" {
  description = "The AWS region. The module uses it only to make the ARN and the function URL."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "memory" {
  description = "The amount of memory, in MB, for the function."
  type        = number
  default     = 128
}

variable "timeout" {
  description = "The time, in seconds, that the function can run."
  type        = number
  default     = 3
}
