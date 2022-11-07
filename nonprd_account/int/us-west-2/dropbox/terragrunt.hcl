include {
  path = find_in_parent_folders()
}

locals {
  global      = jsondecode(file(find_in_parent_folders("global.json")))
  account     = jsondecode(file(find_in_parent_folders("account.json")))
  environment = jsondecode(file(find_in_parent_folders("environment.json", "empty.json")))
  regional    = jsondecode(file(find_in_parent_folders("regional.json", "empty.json")))
  service     = jsondecode(file("${get_terragrunt_dir()}/service.json"))
  settings    = merge(local.global, local.account, local.environment, local.regional, local.service)
}

terraform {
  source = "git::ssh://git@github.com/brycewade/pbio_modules.git//dropbox?ref=mvp"

  extra_arguments "variables" {
    commands = get_terraform_commands_that_need_vars()
  }
}

inputs = local.settings
