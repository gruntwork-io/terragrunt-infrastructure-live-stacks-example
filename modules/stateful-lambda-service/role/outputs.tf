output "name" {
  description = "The name of the IAM role."
  value       = terraform_data.role.output.name
}

output "arn" {
  description = "The ARN of the IAM role."
  value       = terraform_data.role.output.arn
}
