variable "launch_template_name" {
  description = "The name of the launch template."
  type        = string
  default     = ""
}

variable "launch_template_version" {
  description = "A version of the launch template"
  type        = string
  default     = "$Default"
}

variable "name" {
  description = "The name of the Auto Scaling Group."
  type        = string
}

variable "desired_capacity" {
  description = "A number of Amazon EC2 instances in the group."
  type        = number
  default     = 0
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group."
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group."
  type        = number
}

variable "desired_capacity_type" {
  description = "The unit of measurement for the value specified for desired_capacity."
  type        = string
  default     = "units"
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health."
  type        = string
  default     = 120
}

variable "wait_for_capacity_timeout" {
  description = "Maximum duration that Terraform should wait for ASG instances to be healthy before timing out."
  type        = number
  default     = 0
}

variable "tags" {
  description = "The Auto Scaling group tags."
  type        = map(string)
}

variable "mixed_instances_distribution" {
  description = "Mixed instances policy distribution configuration structure."
  type = object({
    on_demand_allocation_strategy            = optional(string, "prioritized")
    on_demand_base_capacity                  = optional(number, 0)
    on_demand_percentage_above_base_capacity = optional(number, 0)
    spot_allocation_strategy                 = optional(string, "capacity-optimized")
    spot_instance_pools                      = optional(number)
    spot_max_price                           = optional(number)
  })
}

variable "single_instance_overrides" {
  description = "Mixed instances policy overrides structure."
  type = list(object({
    instance_type     = optional(string)
    weighted_capacity = optional(number)

    launch_template_specification = optional(object({
      launch_template_id   = optional(string)
      launch_template_name = optional(string)
    }))

  }))
  default = []
}

variable "instance_requirements_override" {
  description = "Override the instance type in the Launch Template with instance types that satisfy the requirements."
  type = object({
    burstable_performance   = optional(string)
    cpu_manufacturers       = optional(set(string))
    excluded_instance_types = optional(set(string))
    instance_generations    = optional(set(string))

    vcpu_count = optional(object({
      max = number
      min = number
    }))

    memory_gib_per_vcpu = optional(object({
      max = number
      min = number
    }))

    memory_mib = optional(object({
      max = number
      min = number
    }))

    on_demand_max_price_percentage_over_lowest_price = optional(number)
    spot_max_price_percentage_over_lowest_price      = optional(number)
  })
  default = {}
}


variable "capacity_rebalance" {
  description = "Whether capacity rebalance is enabled."
  type        = bool
  default     = false
}

variable "default_instance_warmup" {
  description = "Time, in seconds, until a newly launched instance can contribute to the Amazon CloudWatch metrics."
  type        = number
  default     = 60
}

variable "ignore_failed_scaling_activities" {
  description = "Whether to ignore failed Auto Scaling scaling activities while waiting for capacity."
  type        = bool
  default     = false
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the Auto Scaling Group should be terminated."
  type        = list(string)
  default     = ["OldestInstance"]
}

variable "enabled_metrics" {
  description = "A list of metrics to collect."
  type        = list(string)
  default     = []
}

variable "vpc_zone_identifier" {
  description = "A list of VPC subnets."
  type        = list(string)
  default     = []
}

variable "default_cooldown" {
  description = "Amount of time, in seconds, after a scaling activity completes before another scaling activity can start."
  type        = number
  default     = 300
}

variable "schedules" {
  description = "A map of the ASG schedules."
  type = map(object({
    min_size         = optional(number)
    max_size         = optional(number)
    desired_capacity = optional(number)
    start_time       = optional(string)
    end_time         = optional(string)
    time_zone        = optional(string)
    recurrence       = optional(string)
  }))
  default = {}
}

variable "initial_lifecycle_hooks" {
  description = "A map of lifecycle hooks executed during an instance startup."
  type = map(object({
    default_result          = optional(string, "CONTINUE")
    heartbeat_timeout       = optional(number, 600)
    notification_metadata   = optional(string)
    notification_target_arn = optional(string)
    role_arn                = optional(string)
  }))
  default = {}
}

variable "termination_lifecycle_hooks" {
  description = "A map of lifecycle hooks executed during an instance termination."
  type = map(object({
    default_result          = optional(string, "CONTINUE")
    heartbeat_timeout       = optional(number, 600)
    notification_metadata   = optional(string)
    notification_target_arn = optional(string)
    role_arn                = optional(string)
  }))
  default = {}
}
