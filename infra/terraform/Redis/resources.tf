resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_managed_redis" "chat" {
  name                = var.redis_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku_name            = var.sku_name

  high_availability_enabled = var.high_availability_enabled
  public_network_access     = var.enable_private_endpoint ? "Disabled" : "Enabled"

  default_database {
    client_protocol                    = "Encrypted" 
    clustering_policy                  = var.clustering_policy
    eviction_policy                    = var.eviction_policy
    access_keys_authentication_enabled = var.access_keys_authentication_enabled
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.access_keys_authentication_enabled || length(var.client_principal_object_ids) > 0
      error_message = "Access keys are disabled, so set client_principal_object_ids or nobody can connect."
    }
  }
}

# Entra data-plane access (the only policy is "default": full access to commands and keys).
resource "azurerm_managed_redis_access_policy_assignment" "client" {
  for_each = toset(var.client_principal_object_ids)

  managed_redis_id = azurerm_managed_redis.chat.id
  object_id        = each.value
}

#private networking

resource "azurerm_virtual_network" "this" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "vnet-chat-redis"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "private_endpoints" {
  count                = var.enable_private_endpoint ? 1 : 0
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = [var.private_endpoint_subnet_prefix]
}

resource "azurerm_private_dns_zone" "redis" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.redis.azure.net"
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  count                 = var.enable_private_endpoint ? 1 : 0
  name                  = "link-chat-redis"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.redis[0].name
  virtual_network_id    = azurerm_virtual_network.this[0].id
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "redis" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "pe-${var.redis_name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = azurerm_subnet.private_endpoints[0].id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${var.redis_name}"
    private_connection_resource_id = azurerm_managed_redis.chat.id
    subresource_names              = ["redisEnterprise"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "redis-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis[0].id]
  }
}

# ---------------------------------------------------------------- monitoring

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-chat-redis"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# ConnectionEvents (connection + authentication events) are emitted by the databases/default child.
resource "azurerm_monitor_diagnostic_setting" "connection_events" {
  name                       = "connection-events"
  target_resource_id         = "${azurerm_managed_redis.chat.id}/databases/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "ConnectionEvents"
  }
}

