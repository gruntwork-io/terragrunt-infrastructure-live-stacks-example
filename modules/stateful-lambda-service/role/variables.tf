variable "name" {
  description = "The name of the IAM role and of its inline policy."
  type        = string
}

variable "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table that the Lambda function reads and writes."
  type        = string
}

variable "aws_account_id" {
  description = "The ID of the AWS account. The module uses it only to make the ARN."
  type        = string
}
