#
# Launch template
#

variable "create_launch_template" {
  description = "If true, creates a launch template."
  type        = bool
  default     = true
}

variable "launch_template_name" {
  description = "The name of the launch template."
  type        = string
  default     = ""
}

variable "launch_template_description" {
  description = "Description of the launch template."
  type        = string
  default     = null
}

variable "launch_template_version" {
  description = "A version of the launch template"
  type        = string
  default     = "$Default"
}

variable "image_id" {
  description = "The Name of the AMI."
  type        = string
}

variable "key_name" {
  description = "The Name of ssh public key to add to ec2-user account."
  type        = string
}

variable "iam_instance_profile" {
  description = "The IAM Instance Profile to launch the instance with."
  type        = map(string)
}

variable "network_interfaces" {
  description = "A list of network interfaces to be attached to the instance."
  type        = list(any)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to assign to."
  type        = list(string)
  default     = []
}

variable "ebs_optimized" {
  description = "If true, used EC2 instance will be EBS-optimized"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "The type of the instance."
  type        = string
  default     = null
}

variable "metadata_options" {
  description = "Customize the metadata options for the instance."
  type        = map(string)
  default = {
    instance_metadata_tags = "enabled"
  }
}

variable "user_data" {
  description = "The user data to pass to the instance at launch time."
  type        = any
  default     = null
}

variable "launch_template_tag_specifications" {
  description = "Tags being added to EC2, volume and network interface."
  type        = map(string)
  default     = {}
}

variable "launch_template_tags" {
  description = "A map of tags to assign to the launch template."
  type        = map(string)
  default     = {}
}

#
# Auto Scaling Group
#

variable "name" {
  description = "The name of the Auto Scaling Group."
  type        = string
}

variable "desired_capacity" {
  description = "A number of Amazon EC2 instances in the group."
  type        = number
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

variable "use_mixed_instances_policy" {
  description = "Controls the usage of mixed_instances_policy."
  type        = bool
  default     = true
}

variable "mixed_instances_policy" {
  description = "Configuration structure used to launch multiple instance types, On-Demand and Spots within a single ASG."
  type        = any
  default     = null
}

variable "capacity_rebalance" {
  description = "Whether capacity rebalance is enabled."
  type        = bool
  default     = true
}

variable "default_instance_warmup" {
  description = "Time, in seconds, until a newly launched instance can contribute to the Amazon CloudWatch metrics."
  type        = number
  default     = null
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
  type        = map(any)
  default     = {}
}

variable "initial_lifecycle_hooks" {
  description = "A map of lifecycle hooks executed during an instance startup."
  type        = map(any)
  default     = {}
}

variable "termination_lifecycle_hooks" {
  description = "A map of lifecycle hooks executed during an instance termination."
  type        = map(any)
  default     = {}
}
