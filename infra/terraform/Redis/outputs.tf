output "redis_hostname" {
  description = "Connect by hostname (resolves to the private IP inside the VNet)."
  value       = azurerm_managed_redis.chat.hostname
}

output "redis_port" {
  value = azurerm_managed_redis.chat.default_database[0].port
}

output "redis_primary_access_key" {
  description = "Null when access keys are disabled."
  value       = try(azurerm_managed_redis.chat.default_database[0].primary_access_key, null)
  sensitive   = true
}