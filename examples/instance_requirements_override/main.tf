locals {
  name = "fresh-asg"
  tags = { Name = "fresh-asg", Env = "prd" }
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
