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
  ignore_failed_scaling_activities = var.ignore_failed_scaling_activities
  termination_policies             = var.termination_policies
  enabled_metrics                  = var.enabled_metrics
  vpc_zone_identifier              = var.vpc_zone_identifier
  default_cooldown                 = var.default_cooldown


  mixed_instances_policy {
    instances_distribution {
      on_demand_allocation_strategy            = var.mixed_instances_distribution.on_demand_allocation_strategy
      on_demand_base_capacity                  = var.mixed_instances_distribution.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.mixed_instances_distribution.on_demand_percentage_above_base_capacity
      spot_allocation_strategy                 = var.mixed_instances_distribution.spot_allocation_strategy
      spot_instance_pools                      = var.mixed_instances_distribution.spot_instance_pools
      spot_max_price                           = var.mixed_instances_distribution.spot_max_price
    }

    launch_template {
      launch_template_specification {
        launch_template_name = var.launch_template_name
      }

      dynamic "override" {
        for_each = var.single_instance_overrides

        content {
          dynamic "launch_template_specification" {
            for_each = override.value.launch_template_specification != null ? [override.value.launch_template_specification] : []
            content {
              launch_template_name = launch_template_specification.value.launch_template_name
            }
          }

          instance_type     = override.value.instance_type
          weighted_capacity = override.value.weighted_capacity
        }
      }

      dynamic "override" {
        for_each = var.instance_requirements_override != null ? [var.instance_requirements_override] : []
        content {
          instance_requirements {
            burstable_performance   = override.value.burstable_performance
            cpu_manufacturers       = override.value.cpu_manufacturers
            excluded_instance_types = override.value.excluded_instance_types
            instance_generations    = override.value.instance_generations

            dynamic "vcpu_count" {
              for_each = override.value.vcpu_count != null ? [override.value.vcpu_count] : []
              content {
                max = override.value.vcpu_count.max
                min = override.value.vcpu_count.min
              }
            }

            dynamic "memory_gib_per_vcpu" {
              for_each = override.value.memory_gib_per_vcpu != null ? [override.value.memory_gib_per_vcpu] : []
              content {
                max = override.value.memory_gib_per_vcpu.max
                min = override.value.memory_gib_per_vcpu.min
              }
            }

            dynamic "memory_mib" {
              for_each = override.value.memory_mib != null ? [override.value.memory_mib] : []
              content {
                max = override.value.memory_mib.max
                min = override.value.memory_mib.min
              }
            }

            on_demand_max_price_percentage_over_lowest_price = override.value.on_demand_max_price_percentage_over_lowest_price
            spot_max_price_percentage_over_lowest_price      = override.value.spot_max_price_percentage_over_lowest_price
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
      propagate_at_launch = false
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

  min_size         = each.value.min_size
  max_size         = each.value.max_size
  desired_capacity = each.value.desired_capacity
  start_time       = each.value.start_time
  end_time         = each.value.end_time
  time_zone        = each.value.time_zone

  # https://crontab.guru/examples.html
  recurrence = try(each.value.recurrence, null)
}


resource "aws_autoscaling_lifecycle_hook" "launch" {
  for_each = var.initial_lifecycle_hooks

  name                    = each.key
  autoscaling_group_name  = aws_autoscaling_group.main.name
  default_result          = each.value.default_result
  heartbeat_timeout       = each.value.heartbeat_timeout
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
  notification_metadata   = each.value.notification_metadata
  notification_target_arn = each.value.notification_target
  role_arn                = each.value.role_arn
}


resource "aws_autoscaling_lifecycle_hook" "terminate" {
  for_each = var.termination_lifecycle_hooks

  name                    = each.key
  autoscaling_group_name  = aws_autoscaling_group.main.name
  default_result          = each.value.default_result
  heartbeat_timeout       = each.value.heartbeat_timeout
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_metadata   = each.value.notification_metadata
  notification_target_arn = each.value.notification_target_arn
  role_arn                = each.value.role_arn
}
