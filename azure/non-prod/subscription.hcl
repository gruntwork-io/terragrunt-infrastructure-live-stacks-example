# Set subscription-wide variables. These are automatically pulled in to configure the provider and remote state in the
# azure/root.hcl configuration.
locals {
  subscription_name = "non-prod"
  subscription_id   = get_env("EX_NON_PROD_SUBSCRIPTION_ID")
}
