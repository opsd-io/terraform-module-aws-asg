locals {
  name = "fresh-asg"
  asg_enabled_metrics = [
    "GroupAndWarmPoolDesiredCapacity",
    "GroupAndWarmPoolTotalCapacity",
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
  ]
  termination_lifecycle_hooks = {
    graceful_shutdown = {
      heartbeat_timeout = 30,
    }
  }
  tags = { Name = "fresh-asg", Env = "prd" }
}

module "launch_template_amd64" {
  source = "../modules/terraform-module-aws-launch-template"

  name                   = "${local.name}-amd64"
  image_id               = "ami-0a0956a3bacfbf256"
  vpc_security_group_ids = ["sg-09d49e22dafd43ec5", "sg-0ea844093e906d77d"]
  key_name               = "myKey"
  iam_instance_profile   = "myEC2Profile"
  tags                   = local.tags
}

module "asg" {
  source   = "../modules/terraform-module-aws-asg"
  name     = local.name
  min_size = 0
  max_size = 2

  launch_template_name        = module.launch_template_amd64.name
  enabled_metrics             = local.asg_enabled_metrics
  vpc_zone_identifier         = ["subnet-069e5a2ff8aagfdsr"]
  default_cooldown            = 60
  termination_lifecycle_hooks = local.termination_lifecycle_hooks

  mixed_instances_distribution = {
    spot_allocation_strategy = "lowest-price"
    spot_instance_pools      = 2,
    spot_max_price           = 0.06
  }

  instance_requirements_override = {
    instance_generations = ["current"]
    vcpu_count           = { min = 2, max = 4 }
    memory_mib           = { min = 2048, max = 8192 }
  }

  tags = {
    Name  = local.name,
    Env   = "prd",
    Group = local.name
  }
}
