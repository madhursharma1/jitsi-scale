resource "aws_ecs_capacity_provider" "jitsi-cp" {
  name = "jitsi-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.ecs-asg
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 70
    }
  }
}