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
        for_each = var.mixed_instances_overrides

        content {
          dynamic "launch_template_specification" {
            for_each = override.value.launch_template_specification != null ? [override.value.launch_template_specification] : []
            content {
              launch_template_name = launch_template_specification.value.launch_template_name
            }
          }

          dynamic "instance_requirements" {
            for_each = override.value.instance_requirements != null ? [override.value.instance_requirements] : []
            content {
              burstable_performance   = instance_requirements.value.burstable_performance
              cpu_manufacturers       = instance_requirements.value.cpu_manufacturers
              excluded_instance_types = instance_requirements.value.excluded_instance_types
              instance_generations    = instance_requirements.value.instance_generations

              vcpu_count {
                max = instance_requirements.value.vcpu_count_max
                min = instance_requirements.value.vcpu_count_min
              }

              memory_gib_per_vcpu {
                max = instance_requirements.value.memory_gib_per_vcpu_max
                min = instance_requirements.value.memory_gib_per_vcpu_min
              }

              memory_mib {
                max = instance_requirements.value.memory_mib_max
                min = instance_requirements.value.memory_mib_min
              }

              on_demand_max_price_percentage_over_lowest_price = instance_requirements.value.on_demand_max_price_percentage_over_lowest_price
              spot_max_price_percentage_over_lowest_price      = instance_requirements.value.spot_max_price_percentage_over_lowest_price
            }
          }

          instance_type     = override.value.instance_type
          weighted_capacity = override.value.weighted_capacity
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
  notification_target_arn = each.value.notification_target
  role_arn                = each.value.role_arn
}
