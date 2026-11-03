stack "app" {
  // You'll typically want to pin this to a particular version of your catalog repo.
  // e.g.
  // source = "github.com/acme/terragrunt-infrastructure-catalog//stacks/azure-app-foundation?ref=v0.1.0"
  //
  // If you are using a private catalog, you may want to use an SSH source URL instead:
  // source = "git::git@github.com:acme/terragrunt-infrastructure-catalog.git//stacks/azure-app-foundation"
  source = "github.com/gruntwork-io/terragrunt-infrastructure-catalog-example//stacks/azure-app-foundation?ref=azure-examples"

  path = "app"

  values = {
    // Also names the storage account and registry, which are unique across all of Azure.
    name     = "${get_env("EX_APP_PREFIX", "")}appprod"
    location = "eastus"

    enable_alerts = true
  }
}
