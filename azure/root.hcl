# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Azure stacks include this file instead of the root.hcl at the repository root, because `find_in_parent_folders`
# returns the closest match.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load subscription-level variables
  subscription_vars = read_terragrunt_config(find_in_parent_folders("subscription.hcl"))

  # Extract the variables we need for easy access
  subscription_id = local.subscription_vars.locals.subscription_id
  app_prefix      = get_env("EX_APP_PREFIX")
}

# Generate an Azure provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  subscription_id = "${local.subscription_id}"
  features {}
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an Azure Storage account.
#
# Storage account names are unique across all of Azure and limited to 24 characters, so the name is a short hash of
# the app prefix and the subscription.
remote_state {
  backend = "azurerm"
  config = {
    subscription_id      = local.subscription_id
    resource_group_name  = "${local.app_prefix}-tfstate"
    storage_account_name = "tgex${substr(sha1("${local.app_prefix}${local.subscription_id}"), 0, 16)}"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/tofu.tfstate"
    location             = "eastus"

    # Use Entra ID instead of account keys to reach the state, and grant the
    # current identity the blob data role it needs for that.
    use_azuread_auth      = true
    assign_blob_data_role = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Configure what repositories to search when you run 'terragrunt catalog'
catalog {
  urls = [
    "https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example"
  ]
}
