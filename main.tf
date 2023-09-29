locals {
  launch_template         = var.create_launch_template ? aws_launch_template.main[0].name : var.launch_template_name
  launch_template_name    = coalesce(var.launch_template_name, var.name)
  launch_template_version = var.create_launch_template && var.launch_template_version == null ? aws_launch_template.main[0].default_version : var.launch_template_version
}


resource "aws_launch_template" "main" {
  count = var.create_launch_template ? 1 : 0

  name                   = local.launch_template_name
  description            = var.launch_template_description
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  ebs_optimized          = var.ebs_optimized
  user_data              = var.user_data
  vpc_security_group_ids = var.vpc_security_group_ids

  dynamic "network_interfaces" {
    for_each = var.network_interfaces
    content {
      associate_carrier_ip_address = lookup(network_interfaces.value, "associate_carrier_ip_address", null)
      associate_public_ip_address  = lookup(network_interfaces.value, "associate_public_ip_address", null)
      delete_on_termination        = lookup(network_interfaces.value, "delete_on_termination", null)
      description                  = lookup(network_interfaces.value, "description", null)
      device_index                 = lookup(network_interfaces.value, "device_index", null)
      interface_type               = lookup(network_interfaces.value, "interface_type", null)
      ipv4_addresses               = try(network_interfaces.value.ipv4_addresses, [])
      ipv4_address_count           = lookup(network_interfaces.value, "ipv4_address_count", null)
      ipv6_addresses               = try(network_interfaces.value.ipv6_addresses, [])
      ipv6_address_count           = lookup(network_interfaces.value, "ipv6_address_count", null)
      network_interface_id         = lookup(network_interfaces.value, "network_interface_id", null)
      private_ip_address           = lookup(network_interfaces.value, "private_ip_address", null)
      security_groups              = lookup(network_interfaces.value, "security_groups", null)
      subnet_id                    = lookup(network_interfaces.value, "subnet_id", null)
    }
  }

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile != null ? [var.iam_instance_profile] : []
    content {
      name = lookup(var.iam_instance_profile, "name", null)
      arn  = lookup(var.iam_instance_profile, "arn", null)
    }
  }

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", null)
      http_tokens                 = lookup(metadata_options.value, "http_tokens", null)
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", null)
      http_protocol_ipv6          = lookup(metadata_options.value, "http_protocol_ipv6", null)
      instance_metadata_tags      = lookup(metadata_options.value, "instance_metadata_tags", null)
    }
  }

  dynamic "tag_specifications" {
    for_each = toset(["instance", "volume", "network-interface"])
    content {
      resource_type = tag_specifications.key
      tags          = var.launch_template_tag_specifications
    }
  }

  tags = var.launch_template_tags
}

resource "aws_autoscaling_group" "main" {
  name                  = var.name
  desired_capacity      = var.desired_capacity
  min_size              = var.min_size
  max_size              = var.max_size
  capacity_rebalance    = var.capacity_rebalance
  desired_capacity_type = var.desired_capacity_type

  health_check_grace_period        = var.health_check_grace_period
  wait_for_capacity_timeout        = var.wait_for_capacity_timeout
  default_instance_warmup          = var.default_instance_warmup
  ignore_failed_scaling_activities = null
  termination_policies             = var.termination_policies
  enabled_metrics                  = var.enabled_metrics
  vpc_zone_identifier              = var.vpc_zone_identifier
  default_cooldown                 = var.default_cooldown

  dynamic "mixed_instances_policy" {
    for_each = var.use_mixed_instances_policy ? [var.mixed_instances_policy] : []
    content {
      dynamic "instances_distribution" {
        for_each = try([mixed_instances_policy.value.instances_distribution], [])
        content {
          on_demand_allocation_strategy            = try(instances_distribution.value.on_demand_allocation_strategy, null)
          on_demand_base_capacity                  = try(instances_distribution.value.on_demand_base_capacity, null)
          on_demand_percentage_above_base_capacity = try(instances_distribution.value.on_demand_percentage_above_base_capacity, null)
          spot_allocation_strategy                 = try(instances_distribution.value.spot_allocation_strategy, null)
          spot_instance_pools                      = try(instances_distribution.value.spot_instance_pools, null)
          spot_max_price                           = try(instances_distribution.value.spot_max_price, null)
        }
      }

      launch_template {
        launch_template_specification {
          launch_template_name = local.launch_template
          version              = local.launch_template_version
        }

        dynamic "override" {
          for_each = try(mixed_instances_policy.value.override, [])

          content {
            dynamic "instance_requirements" {
              for_each = try([override.value.instance_requirements], [])

              content {
                burstable_performance   = try(instance_requirements.value.burstable_performance, null)
                cpu_manufacturers       = try(instance_requirements.value.cpu_manufacturers, null)
                excluded_instance_types = try(instance_requirements.value.excluded_instance_types, null)
                instance_generations    = try(instance_requirements.value.instance_generations, null)

                dynamic "vcpu_count" {
                  for_each = try([instance_requirements.value.vcpu_count], [])

                  content {
                    max = try(vcpu_count.value.max, null)
                    min = try(vcpu_count.value.min, null)
                  }
                }

                dynamic "memory_gib_per_vcpu" {
                  for_each = try([instance_requirements.value.memory_gib_per_vcpu], [])

                  content {
                    max = try(memory_gib_per_vcpu.value.max, null)
                    min = try(memory_gib_per_vcpu.value.min, null)
                  }
                }

                dynamic "memory_mib" {
                  for_each = try([instance_requirements.value.memory_mib], [])

                  content {
                    max = try(memory_mib.value.max, null)
                    min = try(memory_mib.value.min, null)
                  }
                }

                on_demand_max_price_percentage_over_lowest_price = try(instance_requirements.value.on_demand_max_price_percentage_over_lowest_price, null)
                spot_max_price_percentage_over_lowest_price      = try(instance_requirements.value.spot_max_price_percentage_over_lowest_price, null)
              }
            }

            instance_type = try(override.value.instance_type, null)

            dynamic "launch_template_specification" {
              for_each = try([override.value.launch_template_specification], [])

              content {
                launch_template_name = try(launch_template_specification.value.launch_template_name, null)
              }
            }

            weighted_capacity = try(override.value.weighted_capacity, null)
          }
        }
      }
    }
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}


resource "aws_autoscaling_schedule" "main" {
  for_each = var.schedules

  scheduled_action_name  = each.key
  autoscaling_group_name = aws_autoscaling_group.main.name

  min_size         = try(each.value.min_size, null)
  max_size         = try(each.value.max_size, null)
  desired_capacity = try(each.value.desired_capacity, null)
  start_time       = try(each.value.start_time, null)
  end_time         = try(each.value.end_time, null)
  time_zone        = try(each.value.time_zone, null)

  # https://crontab.guru/examples.html
  recurrence = try(each.value.recurrence, null)
}


resource "aws_autoscaling_lifecycle_hook" "launch" {
  for_each = var.initial_lifecycle_hooks

  name                    = each.key
  autoscaling_group_name  = aws_autoscaling_group.main.name
  default_result          = try(each.value.default_result, "CONTINUE")
  heartbeat_timeout       = try(each.value.heartbeat_timeout, 600)
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
  notification_metadata   = try(each.value.notification_metadata, null)
  notification_target_arn = try(each.value.notification_target, null)
  role_arn                = try(each.value.role_arn, null)
}


resource "aws_autoscaling_lifecycle_hook" "terminate" {
  for_each = var.termination_lifecycle_hooks

  name                    = each.key
  autoscaling_group_name  = aws_autoscaling_group.main.name
  default_result          = try(each.value.default_result, "CONTINUE")
  heartbeat_timeout       = try(each.value.heartbeat_timeout, 600)
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_metadata   = try(each.value.notification_metadata, null)
  notification_target_arn = try(each.value.notification_target, null)
  role_arn                = try(each.value.role_arn, null)
}
