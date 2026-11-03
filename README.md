# Example infrastructure-live for Stategraph Orchestration

This repository describes a small stateful serverless service (an AWS Lambda function, a DynamoDB table, and an IAM role) to two AWS accounts, `non-prod` and `prod`. It is plain OpenTofu. [Stategraph Orchestration](https://stategraph.com/docs/orchestration) plans and applies it from pull requests.

> [!IMPORTANT]
> This is a demo version. The modules do not create AWS resources. Each module has a `terraform_data` resource in place of the AWS resource, and its outputs have the same shape as the outputs of the real resource. Each root module keeps its state in a local `terraform.tfstate` file. Thus you do not need an AWS account, AWS credentials, or a state bucket, and `tofu init` downloads no providers.
>
> The local state files stay on the machine that ran OpenTofu. A CI runner that starts from a new checkout for each job does not keep them. In that case, the `role` and `service` root modules cannot read the state of `db` and `role`, and their plans fail with `Unable to find remote state`.

The repository started as Gruntwork's [terragrunt-infrastructure-live-stacks-example](https://github.com/gruntwork-io/terragrunt-infrastructure-live-stacks-example). It was ported from Terragrunt Stacks to plain OpenTofu and a `.stategraph/config.yml` file. [Terragrunt to Stategraph Orchestration](#terragrunt-to-stategraph-orchestration) shows where each Terragrunt feature went.

> [!NOTE]
> This code is for demonstration only. It is not production-ready.

## Repository contents

```tree
.stategraph/config.yml                  Orchestration configuration: engine, accounts, order, packaging
.github/workflows/terrateam.yml         The workflow that Orchestration starts on GitHub Actions
modules/stateful-lambda-service/        Local modules, one per component. Demo stand-ins for the catalog modules.
  db/                                   DynamoDB table
  role/                                 IAM role that the function uses to read and write the table
  service/                              Lambda function, and its handler source in src/
non-prod/us-east-1/stateful-lambda-service/
  db/                                   Root module: the table for non-prod
  roles/lambda-iam-role-to-dynamodb/    Root module: the role for non-prod
  service/                              Root module: the function for non-prod
prod/us-east-1/stateful-lambda-service/ The same three root modules for prod
scripts/package-lambda.py               Packages the handler source into handler.zip
```

The hierarchy is `account / region / service / component`, as in the Terragrunt version. Each component is a root module with its own state. The root modules are thin: each one calls a module in `modules/stateful-lambda-service/`, and gives it the values for its account. The prod and non-prod root modules differ only in the resource names and the state paths.

The Terragrunt version used the OpenTofu modules of the [terragrunt-infrastructure-catalog-example](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example) repository. In this demo, the modules in `modules/stateful-lambda-service/` have `terraform_data` stand-ins for them. Each stand-in keeps the same inputs and outputs, so you can put the catalog module back without a change to the root modules.

## How Orchestration runs this repository

When a pull request changes a root module, a module it uses, or the handler source, Orchestration plans the affected root modules and comments the plan on the pull request.

- **Order.** `service` reads the outputs of `db` and `role`, and `role` reads the outputs of `db`. The `depends_on` rules in `.stategraph/config.yml` order them. Orchestration plans and applies `db` first, then `role`, then `service`. A component plans only after the components that it depends on are applied.
- **Modules.** The indexer is on in `.stategraph/config.yml`. It reads the `module` blocks of the root modules. A change to a `*.tf` file in `modules/` thus plans each root module that uses that module, and the module directory itself never plans. The indexer adds only `*.tf` files. Thus the `service` entry lists the handler source and the packaging script in `file_patterns`.
- **Accounts.** Each account is a stack in `.stategraph/config.yml`. The stack sets the account ID and the region as `TF_VAR_*` environment variables for each run in that account. The demo modules use them only to make the ARNs.
- **prod after non-prod.** When a pull request changes both accounts, prod applies only after non-prod is applied. The Terragrunt version did not have this order.
- **Packaging.** Before each plan and apply of a `service` root module, a `run` step makes `handler.zip` from `modules/stateful-lambda-service/service/src`. The zip is the same for the same source, so the plan and the apply, which run in different CI jobs, use the same bytes. The demo function keeps the hash of the zip, so a change to the handler source shows in the plan.

To plan again, comment `stategraph plan`. To apply, comment `stategraph apply`. To limit a command to one account, add a tag query, for example `stategraph plan 'non-prod in dir'`.

## Setup

1. Connect the repository to Stategraph Orchestration, on [Stategraph Cloud](https://stategraph.com/docs/get-started/quickstart/cloud) or a [self-hosted](https://stategraph.com/docs/get-started/quickstart/self-hosted) server. Put `.github/workflows/terrateam.yml` on the default branch before you open the first pull request.

2. Optional: change the account IDs in the `stacks` section of `.stategraph/config.yml`. The demo uses them only in the ARNs of the demo resources.

3. Optional: to add a prefix to all resource names, set the GitHub Actions variable `TF_VAR_APP_PREFIX`. The runner gives it to OpenTofu as the `app_prefix` variable. (This was the `EX_APP_PREFIX` environment variable in the Terragrunt version.)

4. Open a pull request that changes the infrastructure, and read the plan comment.

## Run it on your machine

Each root module has its own local state. Apply the root modules of an account in dependency order: `db`, then `role`, then `service`. The `service` root module needs `handler.zip` before each plan and apply.

```bash
export TF_VAR_aws_account_id=123456789012 TF_VAR_aws_region=us-east-1
cd non-prod/us-east-1/stateful-lambda-service

(cd db && tofu init && tofu apply)
(cd roles/lambda-iam-role-to-dynamodb && tofu init && tofu apply)
(cd service \
  && python3 ../../../../scripts/package-lambda.py ../../../../modules/stateful-lambda-service/service/src handler.zip \
  && tofu init && tofu apply)
```

To read an output, for example the function URL:

```bash
cd non-prod/us-east-1/stateful-lambda-service/service
tofu output -raw function_url
```

The URL has the form of a real Lambda function URL, but no function is behind it.

## Terragrunt to Stategraph Orchestration

| Terragrunt | Here |
| --- | --- |
| `terragrunt.stack.hcl` `unit` blocks, generated into `.terragrunt-stack/` | Committed root modules under `<account>/<region>/stateful-lambda-service/` |
| Catalog `units/*` (`terragrunt.hcl`) | Local modules in `modules/stateful-lambda-service/`, with `terraform_data` stand-ins for the catalog modules (demo) |
| `values` and unit `inputs` | Module arguments in the root modules |
| `autoinclude { dependency { config_path } }` | `depends_on` in `.stategraph/config.yml` (order), and `terraform_remote_state` in the root modules (outputs) |
| `mock_outputs` | Not needed. A component plans only after its dependencies are applied. |
| `account.hcl`, `region.hcl`, `find_in_parent_folders` | One stack per account in `.stategraph/config.yml`, with `TF_VAR_*` variables |
| `generate "provider"` | Not needed. The demo modules use no provider. |
| `remote_state` (S3) and `path_relative_to_include()` | `backend "local" {}` in each root module (demo). The state is `<root module directory>/terraform.tfstate`. |
| `--backend-bootstrap` | Not needed. The local backend needs no bucket. |
| `before_hook "package"` and `mark_glob_as_read` | A `run` step with `scripts/package-lambda.py`, and `file_patterns` that include `src/**` |
| `terragrunt run --all plan` / `apply` | Pull request plans, and the `stategraph plan` / `stategraph apply` comments |
| `terragrunt stack output` | Not ported. Use `tofu output` in each root module. |
| `catalog` block and `terragrunt catalog` | Not ported |
| `mise.toml` `opentofu` version | `engine.version` in `.stategraph/config.yml` (also kept in `mise.toml` for local use) |

The Terragrunt version declared its `dependency` blocks but did not give their outputs to the units: the role had no `policy`, and the function had no `iam_role_arn` and no `DYNAMODB_TABLE`. This port gives those values, as the catalog's own example stack does.

## What to do with `.terraform.lock.hcl` files

The demo modules use no provider, so `tofu init` does not create `.terraform.lock.hcl` files. When you use real providers, commit these files in your own repositories. They make sure that the same provider versions are used each time.

## Local tools

To install the pinned OpenTofu version, install [mise](https://mise.jdx.dev/) and run:

```bash
mise install
```
