output "function_url" {
  description = "The URL of the Lambda function."
  value       = terraform_data.function.output.function_url
}

output "function_arn" {
  description = "The ARN of the Lambda function."
  value       = terraform_data.function.output.arn
}

output "function_name" {
  description = "The name of the Lambda function."
  value       = terraform_data.function.output.name
}
