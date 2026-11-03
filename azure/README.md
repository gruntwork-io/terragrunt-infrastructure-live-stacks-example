# Azure example

This directory follows the same layout as the AWS example at the root of this repository, for Azure. It has a `non-prod` and a `prod` environment, each with one stack, and the resources themselves come from the [terragrunt-infrastructure-catalog-example](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example) repository.

Each stack provisions what an application needs before it can run:

- Resource group
- Storage account, with a private `data` blob container and an `items` table
- Basic container registry
- Managed identity for the application, with `AcrPull` on the registry, plus `Storage Blob Data Reader` and `Storage Table Data Contributor` on the storage account
- Alerts on the storage account's availability and latency, in `prod` only

This example doesn't deploy an application, so it ends with the resources above and their outputs.

## Repository contents

- `root.hcl`: The Terragrunt configuration inherited by every unit in this directory. It configures the Azure provider and stores state in Azure Storage. Units use this file instead of the `root.hcl` at the root of the repository, because `find_in_parent_folders` returns the closest match.

- `non-prod`/`prod` directories: Each one represents an Azure subscription.

- `subscription.hcl` files: Each one sets the subscription for that environment. This is the equivalent of the AWS `account.hcl` files.

- `terragrunt.stack.hcl` files: Each one uses the `azure-app-foundation` stack from the catalog.

## Prerequisites

In addition to the tools listed in the [README](/README.md#prerequisites), you'll need the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).

You'll also need the **Owner** or **User Access Administrator** role, because both the state backend and the stack create role assignments. **Contributor** can't do that. See [Required Azure permissions](https://docs.terragrunt.com/features/units/authentication/azure/#required-permissions).

## How to provision the infrastructure

### Setup

1. Log in and select the subscription to deploy into.

   ```bash
   az login
   az account set --subscription "<YOUR_SUBSCRIPTION>"
   ```

2. Set the `EX_NON_PROD_SUBSCRIPTION_ID` and `EX_PROD_SUBSCRIPTION_ID` environment variables to the subscriptions you want to use for non-production and production workloads.

   ```bash
   export EX_NON_PROD_SUBSCRIPTION_ID="$(az account show --query id --output tsv)"
   export EX_PROD_SUBSCRIPTION_ID="$EX_NON_PROD_SUBSCRIPTION_ID"
   ```

   This deploys everything to a single subscription. Both environments then store state in the same storage account, under different keys.

3. Set `EX_APP_PREFIX` to something unique to you, using at most 15 lowercase letters and digits. It's required, because storage account and registry names are unique across all of Azure.

   ```bash
   export EX_APP_PREFIX="acme"
   ```

### Provisioning a single stack

1. Navigate to the directory of the stack you want to provision.

   ```bash
   cd azure/non-prod/eastus/app-foundation
   ```

2. Run the following to generate the relevant units for the stack, and run a plan against them. The `--backend-bootstrap` flag creates the resource group and storage account that hold the state.

   ```bash
   terragrunt run --all --non-interactive --backend-bootstrap plan
   ```

   > [!TIP]
   > If the first run fails while creating the storage account, or with a 403 while reading the container, run it again. Bootstrap picks up what already exists, and Azure can take a few minutes to apply a new role.

3. If the plan looks good, run the following to apply the changes.

   ```bash
   terragrunt run --all --non-interactive apply
   ```

### Provisioning all stacks

To provision both environments, do the same from this directory.

```bash
cd azure
terragrunt run --all --non-interactive --backend-bootstrap plan
terragrunt run --all --non-interactive apply
```

## Interacting with the provisioned infrastructure

1. Get the output values for the stack.

   ```bash
   cd azure/non-prod/eastus/app-foundation
   terragrunt stack output
   ```

2. Use an output to check the access the stack gave the managed identity. Outputs are organized by stack, then unit, then output name.

   ```bash
   az role assignment list --all --assignee "$(terragrunt stack output --raw app.identity.principal_id)" --output table
   ```

## Cleaning up

1. Destroy the infrastructure, from the stack directory or from this directory.

   ```bash
   terragrunt run --all --non-interactive destroy
   ```

2. Delete the resource group that holds the state. Only do this once nothing else stores state there.

   ```bash
   az group delete --name "${EX_APP_PREFIX}-tfstate"
   ```
