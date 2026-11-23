resource "azurerm_container_app_environment" "aca_env" {
  name                           = "${module.this.id}-container-apps-env"
  resource_group_name            = local.resource_group.name
  location                       = var.location
  infrastructure_subnet_id       = local.network.subnet_ids.container_apps
  internal_load_balancer_enabled = true
  zone_redundancy_enabled        = var.zone_redundancy_enabled
  logs_destination               = "azure-monitor"
  log_analytics_workspace_id     = null # local.resources.monitoring.workspace_id
  tags                           = module.this.tags

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }

  dynamic "workload_profile" {
    for_each = var.dedicated_workload_profiles
    content {
      name                  = workload_profile.key
      workload_profile_type = workload_profile.value.workload_profile_type
      minimum_count         = workload_profile.value.minimum_count
      maximum_count         = workload_profile.value.maximum_count
    }
  }
}
