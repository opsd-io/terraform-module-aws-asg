<a href="https://www.opsd.io" target="_blank"><img alt="OPSd" src=".github/img/OPSD_logo.svg" width="180px"></a>

Meet **OPSd**. The unique and effortless way of managing cloud infrastructure.

# terraform-module-aws-asg

## Introduction

Terraform module which creates Auto Scaling resources on AWS

## Usage

```hcl
module "module_name" {
  source  = "github.com/opsd-io/module_name?ref=v0.0.1"

  # Variables
  variable_1 = "foo"
  variable_2 = "bar"
}
```

**IMPORTANT**: Make sure not to pin to master because there may be breaking changes between releases.

### Instance type overrides

Is it possible to define specific instance types by `var.single_instance_overrides` or an instance requirements by `var.instance_requirements_override`.  
These variables are mutually exclusive.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_lifecycle_hook.launch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_lifecycle_hook) | resource |
| [aws_autoscaling_lifecycle_hook.terminate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_lifecycle_hook) | resource |
| [aws_autoscaling_schedule.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity_rebalance"></a> [capacity\_rebalance](#input\_capacity\_rebalance) | Whether capacity rebalance is enabled. | `bool` | `false` | no |
| <a name="input_default_cooldown"></a> [default\_cooldown](#input\_default\_cooldown) | Amount of time, in seconds, after a scaling activity completes before another scaling activity can start. | `number` | `300` | no |
| <a name="input_default_instance_warmup"></a> [default\_instance\_warmup](#input\_default\_instance\_warmup) | Time, in seconds, until a newly launched instance can contribute to the Amazon CloudWatch metrics. | `number` | `60` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | A number of Amazon EC2 instances in the group. | `number` | `0` | no |
| <a name="input_desired_capacity_type"></a> [desired\_capacity\_type](#input\_desired\_capacity\_type) | The unit of measurement for the value specified for desired\_capacity. | `string` | `"units"` | no |
| <a name="input_enabled_metrics"></a> [enabled\_metrics](#input\_enabled\_metrics) | A list of metrics to collect. | `list(string)` | `[]` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Time (in seconds) after instance comes into service before checking health. | `string` | `120` | no |
| <a name="input_ignore_failed_scaling_activities"></a> [ignore\_failed\_scaling\_activities](#input\_ignore\_failed\_scaling\_activities) | Whether to ignore failed Auto Scaling scaling activities while waiting for capacity. | `bool` | `false` | no |
| <a name="input_initial_lifecycle_hooks"></a> [initial\_lifecycle\_hooks](#input\_initial\_lifecycle\_hooks) | A map of lifecycle hooks executed during an instance startup. | <pre>map(object({<br>    default_result          = optional(string, "CONTINUE")<br>    heartbeat_timeout       = optional(number, 600)<br>    notification_metadata   = optional(string)<br>    notification_target_arn = optional(string)<br>    role_arn                = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_instance_requirements_override"></a> [instance\_requirements\_override](#input\_instance\_requirements\_override) | Override the instance type in the Launch Template with instance types that satisfy the requirements. | <pre>object({<br>    burstable_performance   = optional(string)<br>    cpu_manufacturers       = optional(set(string))<br>    excluded_instance_types = optional(set(string))<br>    instance_generations    = optional(set(string))<br><br>    vcpu_count = optional(object({<br>      max = number<br>      min = number<br>    }))<br><br>    memory_gib_per_vcpu = optional(object({<br>      max = number<br>      min = number<br>    }))<br><br>    memory_mib = optional(object({<br>      max = number<br>      min = number<br>    }))<br><br>    on_demand_max_price_percentage_over_lowest_price = optional(number)<br>    spot_max_price_percentage_over_lowest_price      = optional(number)<br>  })</pre> | `{}` | no |
| <a name="input_launch_template_name"></a> [launch\_template\_name](#input\_launch\_template\_name) | The name of the launch template. | `string` | `""` | no |
| <a name="input_launch_template_version"></a> [launch\_template\_version](#input\_launch\_template\_version) | A version of the launch template | `string` | `"$Default"` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum number of instances in the Auto Scaling Group. | `number` | n/a | yes |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum number of instances in the Auto Scaling Group. | `number` | n/a | yes |
| <a name="input_mixed_instances_distribution"></a> [mixed\_instances\_distribution](#input\_mixed\_instances\_distribution) | Mixed instances policy distribution configuration structure. | <pre>object({<br>    on_demand_allocation_strategy            = optional(string, "prioritized")<br>    on_demand_base_capacity                  = optional(number, 0)<br>    on_demand_percentage_above_base_capacity = optional(number, 0)<br>    spot_allocation_strategy                 = optional(string, "capacity-optimized")<br>    spot_instance_pools                      = optional(number)<br>    spot_max_price                           = optional(number)<br>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Auto Scaling Group. | `string` | n/a | yes |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | A map of the ASG schedules. | <pre>map(object({<br>    min_size         = optional(number)<br>    max_size         = optional(number)<br>    desired_capacity = optional(number)<br>    start_time       = optional(string)<br>    end_time         = optional(string)<br>    time_zone        = optional(string)<br>    recurrence       = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_single_instance_overrides"></a> [single\_instance\_overrides](#input\_single\_instance\_overrides) | Mixed instances policy overrides structure. | <pre>list(object({<br>    instance_type     = optional(string)<br>    weighted_capacity = optional(number)<br><br>    launch_template_specification = optional(object({<br>      launch_template_id   = optional(string)<br>      launch_template_name = optional(string)<br>    }))<br><br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The Auto Scaling group tags. | `map(string)` | n/a | yes |
| <a name="input_termination_lifecycle_hooks"></a> [termination\_lifecycle\_hooks](#input\_termination\_lifecycle\_hooks) | A map of lifecycle hooks executed during an instance termination. | <pre>map(object({<br>    default_result          = optional(string, "CONTINUE")<br>    heartbeat_timeout       = optional(number, 600)<br>    notification_metadata   = optional(string)<br>    notification_target_arn = optional(string)<br>    role_arn                = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_termination_policies"></a> [termination\_policies](#input\_termination\_policies) | A list of policies to decide how the instances in the Auto Scaling Group should be terminated. | `list(string)` | <pre>[<br>  "OldestInstance"<br>]</pre> | no |
| <a name="input_vpc_zone_identifier"></a> [vpc\_zone\_identifier](#input\_vpc\_zone\_identifier) | A list of VPC subnets. | `list(string)` | `[]` | no |
| <a name="input_wait_for_capacity_timeout"></a> [wait\_for\_capacity\_timeout](#input\_wait\_for\_capacity\_timeout) | Maximum duration that Terraform should wait for ASG instances to be healthy before timing out. | `number` | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name (ARN) of the Auto Scaling Group. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Auto Scaling Group. |
<!-- END_TF_DOCS -->

## Examples of usage

Do you want to see how the module works? See all the [usage examples](examples).

## Related modules

The list of related modules (if present).

## Contributing

If you are interested in contributing to the project, see see our [guide](https://github.com/opsd-io/contribution).

## Support

If you have a problem with the module or want to propose a new feature, you can report it via the project's (Github) issue tracker.

If you want to discuss something in person, you can join our community on [Slack](https://join.slack.com/t/opsd-community/signup).

## License

[Apache License 2.0](LICENSE)
