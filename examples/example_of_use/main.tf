module "asg" {
  source             = "../modules/terraform-module-aws-asg"
  name               = "fresh-asg"
  desired_capacity   = 0
  min_size           = 0
  max_size           = 2
  capacity_rebalance = false

  default_instance_warmup     = 60
  enabled_metrics             = local.asg_enabled_metrics
  vpc_zone_identifier         = ["subnet-069e5a2ff8aagfdsr"]
  default_cooldown            = 60
  termination_lifecycle_hooks = local.termination_lifecycle_hooks


  image_id               = "ami-0a0956a3bacff5342"
  vpc_security_group_ids = ["sg-09d49e22dafd43ddd", "sg-0ea844093e906d7ss"]
  user_data              = "IyEvYmluL2Jhc2gKI0ZvciB1c2Ugd2l0aCB0aGUgQVNHIHVzZXIgZGF0YSBzZWN0aW9uIG9mIExhdW5jaCBDb25maWdzIHB1c2ggbXExClNUQVJUVElNRT0kKGRhdGUgKyVzJU4gfCBjdXQgLWIxLTEzKQpzdWRvIC9iaW4vYmFzaCAvb3B0L3NjcmlwdHMvZGVwbG95LnNoIG1xMQpzdWRvIC9iaW4vYmFzaCAvZXRjL2luaXQuZC9wdXNoIHN0YXJ0"
  key_name               = local.ssh_key_name
  iam_instance_profile   = local.ec2_iam_instance_profile
  launch_template_tag_specifications     = { Name = "fresh-asg", Env = "prd" }

  mixed_instances_policy = {

    instances_distribution = {
      on_demand_allocation_strategy            = "prioritized",
      on_demand_base_capacity                  = 0,
      on_demand_percentage_above_base_capacity = 0,
      spot_allocation_strategy                 = "lowest-price"
      spot_instance_pools                      = 2,
      spot_max_price                           = 0.5
    }

    override = [
      {
        instance_type = "m7a.xlarge"
      },
      {
        instance_type                 = "c7g.xlarge"
        launch_template_specification = { launch_template_name = "fresh-asg-arm64" }
      },
      {
        instance_type = "c6a.xlarge"
      },
      {
        instance_type                 = "m7g.xlarge"
        launch_template_specification = { launch_template_name = "fresh-asg-arm64" }
      },
      {
        instance_type = "m5zn.xlarge"
      },
      {
        instance_type = "c5.xlarge"
      },
      {
        instance_type = "m5.xlarge"
      },
      {
        instance_type = "r6a.xlarge"
      },
      {
        instance_type = "c5a.xlarge"
      },
      {
        instance_type = "m5a.xlarge"
      },
    ]
  }

  asg_tags = {
    Name  = "fresh-asg",
    Env   = "prd",
    Group = "fresh-asg"
  }
}