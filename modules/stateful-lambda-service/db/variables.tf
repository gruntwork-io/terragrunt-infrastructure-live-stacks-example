variable "name" {
  description = "The name of the DynamoDB table."
  type        = string
}

variable "hash_key" {
  description = "The hash key of the DynamoDB table."
  type        = string
}

variable "hash_key_type" {
  description = "The type of the hash key (S for string, N for number)."
  type        = string
}

variable "billing_mode" {
  description = "The billing mode of the DynamoDB table (PAY_PER_REQUEST or PROVISIONED)."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "aws_account_id" {
  description = "The ID of the AWS account. The module uses it only to make the ARN."
  type        = string
}

variable "aws_region" {
  description = "The AWS region. The module uses it only to make the ARN."
  type        = string
}
