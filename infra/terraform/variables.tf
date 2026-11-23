

variable "zone_redundancy_enabled" {
  type    = bool
  default = true
}

variable "dedicated_workload_profiles" {
  type = map(object({
    workload_profile_type = string
    minimum_count         = optional(number, 1)
    maximum_count         = optional(number, 3)
  }))
  default = {}
}

variable "location" {
  type    = string
  default = "francecentral"
}

# Redis

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}


variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
}

variable "vnet_address_space" {
  description = "VNet CIDR block"
  type        = string
}

variable "subnet_redis_prefix" {
  description = "Subnet CIDR for Redis private endpoint"
  type        = string
}

variable "subnet_app_prefix" {
  description = "Subnet CIDR for application workloads"
  type        = string
}

variable "redis_name" {
  description = "Azure Managed Redis instance name (must be globally unique)"
  type        = string
}

variable "redis_sku_name" {
  description = "Azure Managed Redis SKU (Balanced_B0, B1, B5, B10 ...)"
  type        = string
}

variable "redis_high_availability_enabled" {
  description = "Enable zone-redundant high availability"
  type        = bool
  default     = true
}

variable "redis_clustering_policy" {
  description = "OSSCluster or EnterpriseCluster"
  type        = string
}

variable "redis_eviction_policy" {
  description = "Eviction policy — AllKeysLRU is ideal for chat history"
  type        = string
  default     = "NoEviction"
}

variable "redis_rdb_backup_frequency" {
  description = "RDB snapshot frequency in seconds (3600=1h, 21600=6h, 43200=12h)"
  type        = string
  default     = "3600"
}