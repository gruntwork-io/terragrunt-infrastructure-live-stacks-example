# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# root.hcl configuration.
locals {
  account_name   = "prod"
  aws_account_id = "replaceme" # TODO: replace me with your AWS account ID!
}
