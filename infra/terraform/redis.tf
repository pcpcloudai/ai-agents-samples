resource "azurerm_managed_redis" "main" {
  name                      = var.redis_name
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = var.location

  sku_name                  = var.redis_sku_name
  high_availability_enabled = var.redis_high_availability_enabled
  public_network_access     = "Disabled"

  default_database {
    client_protocol   = "Encrypted"
    clustering_policy = var.redis_clustering_policy
    eviction_policy   = var.redis_eviction_policy

    access_keys_authentication_enabled = false

    module {
      name = "RedisJSON"
    }
    module {
      name = "RediSearch"
    }

    
    persistence_rdb_backup_frequency = var.redis_rdb_backup_frequency
  }

  tags = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

# Private DNS Zone

resource "azurerm_private_dns_zone" "redis" {
  name                = "privatelink.redisenterprise.cache.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  name                  = "dnslink-redis"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.redis.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = local.common_tags
}

# Private Endpoint

resource "azurerm_private_endpoint" "redis" {
  name                = "pe-redis"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.pe.id
  tags                = local.common_tags

  private_service_connection {
    name                           = "psc-redis"
    private_connection_resource_id = azurerm_managed_redis.main.id
    is_manual_connection           = false
    subresource_names              = ["redisEnterprise"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis.id]
  }
}