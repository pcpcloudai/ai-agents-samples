

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