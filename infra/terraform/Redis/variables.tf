variable "subscription_id" {
  description = "Azure subscription."
  type        = string
}

variable "resource_group_name" {
  type    = string
  default = "rg-chat-redis"
}

variable "location" {
  description = "Region with availability zones"
  type        = string
  default     = " westeurope"
}

variable "redis_name" {
  description = "Azure Managed Redis name"
  type        = string
  default     = "amr-chat-context-001"
}

variable "sku_name" {
  description = "Balanced_* for general use; benchmark with real message sizes and concurrency."
  type        = string
  default     = "Balanced_B1"
}

variable "high_availability_enabled" {
  description = "Replica shards + automatic failover; zone redundant where supported. false only for disposable dev/test."
  type        = bool
  default     = true
}



variable "eviction_policy" {
  description = "set a time limit for every chat stored"
  type        = string
  default     = "VolatileLRU"
}

variable "enabled_access_keys_auth" {
  description = "Entra"
  type        = bool
  default     = false
}



variable "enable_private_endpoint" {
  description = "Use Virtual Network, disable public network access, private DNS and private endpoint"
  type        = bool
  default     = true
}

variable "vnet_address_space" {
  type    = string
  default = "10.20.0.0/16"
}

variable "private_endpoint_subnet_prefix" {
  type    = string
  default = "10.20.1.0/24"
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "tags" {
}
