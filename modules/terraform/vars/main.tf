locals {
  workspace_vars = fileexists("${var.vars_folder}/${terraform.workspace}.yml") ? "${terraform.workspace}.yml" : var.default_vars_file
  envs = merge(
      # Create an object with default variables
      # default = { "var1" = "value1" }
      { default = yamldecode(file("${var.vars_folder}/${var.default_vars_file}")) },
      { "${terraform.workspace}" = yamldecode(file("${var.vars_folder}/${local.workspace_vars}")) },
      
      # Create an object of environments out of provoded YAML files
      # e.g 
      # {
      #   prod = { "var1" = "value1" }
      #   dev = { "var1" = "value1"}
      # }
      # {
      #   for env_name, filename in var.input_var_files:
      #     env_name =>
      #       yamldecode(file("${var.vars_folder}/${filename}")) 
      # }
    )
  # Get current workspace name
  env_vars = "${contains(keys(local.envs), terraform.workspace) ? terraform.workspace : "default"}"
  # Merge default variables and workspace variables
  workspace = "${merge(local.envs["default"], local.envs[local.env_vars])}"
}
