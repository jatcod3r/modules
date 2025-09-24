locals {
  days_of_week = toset(["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"])
}

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = var.path
  output_path = "/tmp/coder-${var.name}"
}

resource "coderd_template" "template" {
  name                              = var.name
  display_name                      = var.display_name
  description                       = var.description
  icon                              = var.icon
  organization_id                   = var.org_id
  require_active_version            = var.require_active_version
  allow_user_auto_start             = true
  allow_user_auto_stop              = true
  auto_start_permitted_days_of_week = local.days_of_week
  default_ttl_ms                    = 10800000
  auto_stop_requirement = {
    days_of_week = local.days_of_week
  }
  versions = [
    {
      directory = var.path
      active    = true
      tf_vars = [{
        name  = "workspaces_namespace"
        value = "coder-workspace"
      }]
    }
  ]
}