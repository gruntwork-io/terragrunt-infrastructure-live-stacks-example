# The `non-prod` stack in `.stategraph/config.yml` sets these values as `TF_VAR_*` environment variables.
variable "aws_account_id" {
  description = "The ID of the AWS account. The demo modules use it only to make ARNs."
  type        = string
}

variable "aws_region" {
  description = "The AWS region."
  type        = string
}

# Set it with the GitHub Actions variable TF_VAR_APP_PREFIX. The runner copies it to TF_VAR_app_prefix.
variable "app_prefix" {
  description = "An optional prefix for all resource names."
  type        = string
  default     = ""
}
