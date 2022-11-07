# Read in our (relative) config files
locals {
  global      = jsondecode(file(find_in_parent_folders("global.json")))
  account     = jsondecode(file(find_in_parent_folders("account.json")))
  environment = jsondecode(file(find_in_parent_folders("environment.json", "empty.json")))
  regional    = jsondecode(file(find_in_parent_folders("regional.json", "empty.json")))
  service     = jsondecode(file(find_in_parent_folders("service.json", "empty.json")))
  settings = merge(
    local.global,
    local.account,
    local.environment,
    local.regional,
    local.service
  )
}

# Creates a provider.tf to pass in default provider values.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.settings.region}"

  default_tags {
    tags = ${jsonencode(local.settings.default_tags)}
  }
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "terraform-state-${local.settings.region}-${get_aws_account_id()}"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.settings.region
  }
}