[![Maintained by Gruntwork.io](https://img.shields.io/badge/maintained%20by-gruntwork.io-%235849a6.svg)](https://gruntwork.io/?ref=repo_terragrunt-infra-live-example)

# Example infrastructure-live for Terragrunt (with Stacks)

This repository, along with the [terragrunt-infrastructure-catalog-example repository](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example),
offers a best practice system for organizing your Infrastructure as Code (IaC) so that you can maintain your IaC at any
scale with confidence using an `infrastructure-live` repository.

If you have not already done so, you are encouraged to read the [Terragrunt Getting Started Guide](https://terragrunt.gruntwork.io/docs/getting-started/quick-start/) to get familiar with the terminology and concepts used in this repository before proceeding.

## What is an `infrastructure-live` repository?

An `infrastructure-live` repository is a Gruntwork best practice for managing your "live" infrastructure. That is, the
infrastructure that is actually provisioned, as opposed to infrastructure patterns that *can* be provisioned.

## Key Features & Benefits

This repository provides a practical blueprint for managing infrastructure with Terragrunt, demonstrating:

* **Modern Terragrunt Workflow:** Leverages Terragrunt Stacks for clear dependency management and streamlined multi-component deployments.
* **Scalable `infrastructure-live` Structure:** Organizes infrastructure logically by account and region, providing a proven foundation adaptable to growing complexity.
* **Best-Practice Separation:** Clearly separates environment-specific "live" configurations (this repo) from reusable infrastructure patterns (via an `infrastructure-catalog`).
* **DRY Configuration:** Reduces code duplication using hierarchical configuration files (`root.hcl`, `account.hcl`, `region.hcl`).
* **Concrete End-to-End Example:** Deploys a sample stateful web application (ASG, ALB, MySQL) across distinct production and non-production environments.
* **Reproducible Tooling:** Includes `mise` configuration for easy installation of pinned versions of Terragrunt and OpenTofu/Terraform.

## Getting Started

> [!TIP]
> If you have an existing repository that was started using the [terragrunt-infrastructure-live-example](https://github.com/gruntwork-io/terragrunt-infrastructure-live-example) repository as a starting point, follow the [migration guide](/docs/migration-guide.md) for help in adjusting your existing configurations to take advantage of the patterns outlined in this repository.

To use this repository, you'll want to fork this repository into your own Git organization.

The steps for doing this are the following:

1. Create a new Git repository in your organization (e.g. [GitHub](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository), [GitLab](https://docs.gitlab.com/user/project/repository/)).

2. Create a bare clone of this repository somewhere on your local machine.

   ```bash
   git clone --bare https://github.com/gruntwork-io/terragrunt-infrastructure-live-stacks-example.git
   ```

3. Push the bare clone to your new Git repository.

   ```bash
   cd terragrunt-infrastructure-live-stacks-example.git
   git push --mirror <YOUR_GIT_REPO_URL> # e.g. git push --mirror git@github.com:acme/terragrunt-infrastructure-live-stacks-example.git
   ```

4. Remove the local clone of the repository.

   ```bash
   cd ..
   rm -rf terragrunt-infrastructure-live-stacks-example.git
   ```

5. (Optional) Delete the contents of this usage documentation from your fork of this repository.

## Prerequisites

To use this repository, you'll want to make sure you have the following installed:

- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [OpenTofu](https://opentofu.org/docs/intro/install/) (or [Terraform](https://developer.hashicorp.com/terraform/install))

To simplify the process of installing these tools, you can install [mise](https://mise.jdx.dev/), then run the following to concurrently install all the tools you need, pinned to the versions they were tested with (as tracked in the [mise.toml](./mise.toml) file):

```bash
mise install
```

## Repository Contents

> [!NOTE]
> This code is solely for demonstration purposes. This is not production-ready code, so use at your own risk. If you are interested in battle-tested, production-ready Terragrunt and OpenTofu/Terraform code, continuously updated and maintained by a team of subject matter experts, consider purchasing a subscription to the [Gruntwork IaC Library](https://www.gruntwork.io/platform/iac-library).

This repository contains the following:

- `root.hcl`: The root Terragrunt configuration inherited by all other Terragrunt units in this repository.

- `non-prod`/`prod` directories: Each of these directories are a representation of an AWS account, and all the infrastructure that's provisioned for an account can be found in the respective directory.

- `account.hcl` files: In each account directory, there is an `account.hcl` file that defines the common configurations for that account.

- `region.hcl` files: In each region directory (e.g. `us-east-1`), there is a `region.hcl` file that defines the common configurations for that region.

- `root.hcl`: The root Terragrunt configuration inherited by all other Terragrunt units in this repository. This file contains code that reads the `account.hcl` and `region.hcl` files in every unit, and leverages them for provider and backend configurations.

- `terragrunt.stack.hcl` files: These files define a stack of Terragrunt units.

  Both the `terragrunt.stack.hcl` files in this repository provision the units required for a stateful ASG service, including:

  - EC2 Auto Scaling Group (ASG)
  - Application Load Balancer (ALB)
  - Security Groups (SGs)
  - MySQL Database (DB)

  The configurations for these resources aren't defined in this repository, but are instead defined in the [terragrunt-infrastructure-catalog-example](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example) repository.

  This is a recommended, Gruntwork best practice, as it allows infrastructure teams to iterate on infrastructure patterns as versioned, immutable artifacts, and then reference pinned versions of these patterns in their "live" infrastructure-live repositories.

## Best practices for an `infrastructure-live` repository

The following conventions are some best practices for an `infrastructure-live` repository, as defined by Gruntwork:

- Primarily use [Terragrunt](https://terragrunt.gruntwork.io/) configurations to define your IaC.
- Avoid using OpenTofu/Terraform directly in `infrastructure-live` repositories. Instead, prefer to author them in an `infrastructure-catalog` repository (see [terragrunt-infrastructure-catalog-example](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example)).
- Follow [Trunk-Based Development](https://trunkbaseddevelopment.com/). The source of truth for your infrastructure is the code in the `main` branch (or whatever you configure the default branch to be).
- Avoid using [OpenTofu/Terraform Workspaces](https://opentofu.org/docs/language/state/workspaces/). Instead, use [Terragrunt units](https://terragrunt.gruntwork.io/docs/getting-started/terminology/#unit) to isolate state.
- Use [Stacks](https://terragrunt.gruntwork.io/docs/getting-started/terminology/#stack) to organize your infrastructure into logical collections of units.

## How to provision the infrastructure in this repository

### Setup

Before you start provisioning the infrastructure in this repository, you'll want to do the following:

1. Update the `bucket` attribute of the `remote_state` block in the `root.hcl` file to a unique name.

   ```hcl
   remote_state {
     backend = "s3"
     config = {
       encrypt        = true
       # vvvvv Replace this vvvvvv
       bucket         = "${get_env("TG_BUCKET_PREFIX", "")}terragrunt-example-tf-state-${local.account_name}-${local.aws_region}"
       # ^^^^^ Replace this ^^^^^^
       key            = "${path_relative_to_include()}/tf.tfstate"
       region         = local.aws_region
       use_lockfile   = true
     }
     generate = {
       path      = "backend.tf"
       if_exists = "overwrite_terragrunt"
     }
   }
   ```

   Alternatively, you can set the `TG_BUCKET_PREFIX` environment variable to set a custom prefix. S3 bucket names must be globally unique across all AWS customers, so you'll have to make sure that the value you choose doesn't conflict with any existing bucket names.

2. Update the `account_name` and `aws_account_id` parameters in [`non-prod/account.hcl`](/non-prod/account.hcl) and [`prod/account.hcl`](/prod/account.hcl) with the names and IDs of accounts you want to use for non production and production workloads, respectively.

   > [!TIP]
   > If you want everything deployed in a single AWS account, you can just use different values for the `account_name` parameter, and keep the `aws_account_id` parameter the same.

3. Configure your local AWS credentials using one of the supported [authentication mechanisms](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

### Provisioning a single stack

1. Navigate to the directory of the stack you want to provision.
   e.g.

   ```bash
   cd non-prod/us-east-1/stateful-ec2-asg-service
   ```

2. Run the following to generate the relevant units for the stack, and run a plan against them.

   ```bash
   terragrunt run --all --non-interactive --bootstrap-backend plan
   ```

   > [!TIP]
   >
   > The `--bootstrap-backend` flag there allows Terragrunt to automatically create relevant backend resources for you before running OpenTofu.
   >
   > You don't need to use the flag if you are using backend resources that already exist, or don't want Terragrunt to create them for you.

3. If the plan looks good, run the following to apply the changes.

   ```bash
   terragrunt run --all --non-interactive apply
   ```

### Provisioning all stacks

If you want to provision all the stacks in this repository, you can do the same at the root of the repository.

1. Navigate back up to the root of the repository.

   ```bash
   cd ../../..
   ```

2. Plan all units.

   ```bash
   terragrunt run --all --non-interactive plan
   ```

3. Apply all units.

   ```bash
   terragrunt run --all --non-interactive apply
   ```

## Interacting with the provisioned infrastructure

If you'd like to interact with the infrastructure that was just provisioned, you can do the following:

1. Get the output values for the stack that you just provisioned.

   ```bash
   $ cd non-prod/us-east-1/stateful-ec2-asg-service
   $ terragrunt stack output
   service = {
     alb_dns_name          = "stateful-asg-service-XXXXXXXXXX.us-east-1.elb.amazonaws.com"
     alb_security_group_id = "sg-XXXXXXXXXXXX"
     asg_name              = "terraform-XXXXXXXXXXXXXXXXXXXXXXXX"
     asg_security_group_id = "sg-XXXXXXXXXXXX"
     url                   = "http://stateful-asg-service-XXXXXXXXXX.us-east-1.elb.amazonaws.com:80"
   }
   sg_to_db_sg_rule = null
   asg_sg = {
     id = "sg-XXXXXXXXXXXX"
   }
   db = {
     arn                  = "arn:aws:rds:us-east-1:XXXXXXXXXXXX:db:terraform-XXXXXXXXXXXXXXXXXXXXXXXX"
     db_name              = "statefulasgservicedb"
     db_security_group_id = "sg-XXXXXXXXXXXX"
     endpoint             = "terraform-XXXXXXXXXXXXXXXXXXXXXXXX.XXXXXXXXXXXX.us-east-1.rds.amazonaws.com:3306"
   }
   ```

   Note that all the units in the stack display their outputs here. Outputs are organized by stack, then unit, then output name.

2. Use the output values to interact with the infrastructure.

   ```bash
   $ URL="$(terragrunt stack output --raw service.url)"
   $ curl $URL
   OK
   $ curl $URL/movies
   [{"id":1,"title":"The Matrix","releaseYear":1999},{"id":2,"title":"The Matrix Reloaded","releaseYear":2003},{"id":3,"title":"The Matrix Revolutions","releaseYear":2003}]
   ```

   Outputs can be indexed by output key. In this case, the `service` unit has an output key of `url`, so we can access it directly with `service.url`. When outputs are nested into stacks, you can access them by chaining the stack name, unit name, and output key.

## How is the code in this repository organized?

The IaC code in this repository is organized into a hierarchy of Terragrunt stacks, representing the blast radius of the infrastructure being managed in the context of AWS infrastructure management.

The hierarchy is as follows:

```tree
account
 └ region
    └ resources
```

Where:

- `account` is the AWS account being managed (e.g. `non-prod`, `prod`, `mgmt`).
- `region` is the AWS region being managed (e.g. `us-east-1`).
- `resources` are the resources being managed (e.g. `stateful-ec2-asg-service`).

This structure is geared towards exclusive management of infrastructure in AWS, but can be adapted to other cloud providers, etc. by adjusting the hierarchy according to the patterns of the platform.

The top-level `account` and `region` directories are there to give clear context for users that are familiar with AWS infrastructure management. Authentication and configuration of the OpenTofu AWS provider is specific to the AWS account and region, so it's also useful to have these directories to provide a straight-forward way to configure the provider.

Many teams like to organize their environments into individual AWS accounts, and this structure makes it easy to do that. If you are part of a team that manages multiple environments in a single AWS account, you can simply add a new level of hierarchy under the `region` directory, like this:

```tree
account
 └ region
    └ environment
       └ resources
```

There's also an established convention to leverage a special `_global` directory to manage resources that are available across all regions, environments, etc. Structuring your IaC like that would look like this:

```tree
account
 ├ _global
 │  └ resources
 └ region
    ├ _global
    │  └ resources
    └ environment
       └ resources
```

Where:

- **Account-level `_global`**: Contains resources that are available across all regions in the account, such as IAM users, Route 53 hosted zones, and CloudTrail.
- **Region-level `_global`**: Contains resources that are available across all environments in a region, such as Route 53 A records, SNS topics, and ECR repositories.

The `resources` directory can be arbitrarily deep, and can be used to organize resources under management in a way that makes sense for the team managing the infrastructure. In this repository it's fairly shallow for the sake of simplicity, with the units constituting the stack in the `terragrunt.stack.hcl` files defined in the [terragrunt-infrastructure-catalog-example](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example) repository.

## Where to store configuration

### `root.hcl`

The contents of the `root.hcl` file is configuration that is common to all units the repository. It's idiomatic Terragrunt code to always include this root file in every unit. There's very frequently some boilerplate configuration like defining the OpenTofu provider, setting state backend configurations, etc. that have to be repeated in every unit, so it's nice to have it defined once in the root file, and included in every unit.

Avoid overloading this file with too much configuration, as it might not be the right level of abstraction for the configuration you need. Instead, prefer to use `terragrunt.stack.hcl` files to define configurations in `values` attributes, and pass down the values to the stacks and units that need them.

### `terragrunt.stack.hcl`

The `terragrunt.stack.hcl` file is used to define configurations for a stack of Terragrunt units. Any time you have multiple `terragrunt.hcl` files that need to be run together as part of your infrastructure deployment, you can define a `terragrunt.stack.hcl` file instead to encapsulate those configurations as a single entity that can be reliably reproduced across accounts, regions, environments, etc.

Using the `values` attribute of [stack](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#stack) and [unit](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#unit) configuration blocks allows you to pass down configuration to units with granular control.

For example, consider this portion of the [prod/us-east-1/stateful-ec2-asg-service/terragrunt.stack.hcl](prod/us-east-1/stateful-ec2-asg-service/terragrunt.stack.hcl) file:

```hcl
unit "service" {
  // You'll typically want to pin this to a particular version of your catalog repository.
  // e.g.
  // source = "github.com/acme/terragrunt-infrastructure-catalog//units/ec2-asg-stateful-service?ref=v0.1.0"
  //
  // If you are using a private catalog, you may want to use an SSH source URL instead:
  // source = "git::git@github.com:acme/terragrunt-infrastructure-catalog.git//units/ec2-asg-stateful-service"
  source = "github.com/gruntwork-io/terragrunt-infrastructure-catalog-example//units/ec2-asg-stateful-service"

  path = "service"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    name          = local.name
    instance_type = "t4g.micro"
    min_size      = 2
    max_size      = 4
    server_port   = 3000
    alb_port      = 80

    db_path     = "../db"
    asg_sg_path = "../sgs/asg"

    // This is used for the userdata script that
    // bootstraps the EC2 instances.
    db_username = local.db_username
    db_password = local.db_password
  }
}
```

Here, you can see that the `values` attribute is setting exactly the values that are unique to the `service` unit in the context of the `stateful-ec2-asg-service` stack, including the `version` of the OpenTofu module it uses, and the relative paths to the dependencies it relies on (e.g. the `db` and `asg_sg` units).

## What to do with `.terraform.lock.hcl` files

When you run `terragrunt` commands you may find that `.terraform.lock.hcl` files are created in your working directories.

These files are intentionally not committed to this example repository, but definitely should be in your own repositories!

They help make sure that your IaC results in reproducible infrastructure. For more on this, read [Lock File Handling docs](https://terragrunt.gruntwork.io/docs/features/lock-file-handling/).

## How to get help

If you need help troubleshooting usage of this repository, or Terragrunt in general, check out the [Support docs](https://terragrunt.gruntwork.io/docs/community/support/).
