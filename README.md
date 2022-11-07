# pbio_infrastructure

This repo contains the building blocks for Terragrunt deployments

## Layout

This repository is layed out to create the skeleton for deployments.  It is set up for a global top level with terrarunt.hcl setup and a global configuration file (`global.json`) that apply to all accounts/environments/regions.

Below the global layer are directories for the different AWS accounts, in this case simply `nonprod_account` and `prd_account`.  Each of these have their own `account.json` configuration file.

Below the account level there are environmental directories.  Each of these directories has its own `environment.json` configuration file.

For each environment there may be multiple regions with resources deployed.  In this skeleton only the `us-west-2` environment is configured.  Each region contains its own `regional.json` configuration file.

Finally for each region there are different module directories, each with their own `service.json` file with configurations unique to that particular module.

When deploying modules Terragrunt will merge all appropriate config files above to determine the total configuration.  The merge is from least specific (`global.json`) down to the most specific (`service.json`).  i.e. something defined in `global.json` could be overridden by the same setting in the appropriate `account.json`, `environment.json`, `regional.json`, or `service.json` files, while something set in `regional.json` can only be overridden by settings in `service.json`

## Deployment

### One module at a time

For a simple deployment of one module cd into the appropriate infrastructure directory for that module.  i.e. to deply the dropbox in the non-prod account, in the dev environment, in the us-west-2 region change directory into `/<top of repo>/nonprd_account/dev/us-west-2/dropbox` and run the `terragrunt apply` command.  I recommend running this with the "--terragrunt-source-update" flag as well.

```bash
cd /pbio/pbio_infrastructure/nonprd_account/dev/us-west-2/dropbox
terragrunt apply --terragrunt-source-update
```

### Deploying an entire environment at a time

To deploy an entire environment at a time is similar, but change directory to the top of the environment, and run "terragrunt run-all apply" (again I recommend to use the "--terragrunt-source-update" flag).

```bash
cd /pbio/pbio_infrastructure/nonprd_account/dev
terragrunt run-all apply --terragrunt-source-update
```

## TODO:
* Create a build-tools container that has all the appropriate programs installed, and at the correct versions.  Use this container for all deployments (automated or manual)
* Automatically deploy to the dev environment when new code is
pushed/merged into the main branch.
* Create unit and integration tests to verify everything is working.
* Create pipeline to automatically promote to higher environments once deployed and tested in lower environments.
* Make sure any pipelines use a purpose built role instead of a user's access key to do their deployments