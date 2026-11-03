output "name" {
  description = "The name of the DynamoDB table."
  value       = terraform_data.table.output.name
}

output "arn" {
  description = "The ARN of the DynamoDB table."
  value       = terraform_data.table.output.arn
}
