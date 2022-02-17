data "aws_vpc" "jitsi-vpc" {
 tags = {
   Name = "vpc-jitsi"
 } 
}

data "aws_subnet_ids" "private-subnets" {
  vpc_id = data.aws_vpc.jitsi-vpc.id
  filter {
    name   = "tag:Name"
    values = ["jitsi-private-*"]
  }
}

data "aws_subnet_ids" "public-subnets" {
  vpc_id = data.aws_vpc.jitsi-vpc.id
  filter {
    name   = "tag:Name"
    values = ["jitsi-public-*"]
  }
}

output "jitsi-vpc" {
  value = data.aws_vpc.jitsi-vpc.id
}

output "private-subnets" {
  value = data.aws_subnet_ids.private-subnets.ids
}

output "public-subnets" {
  value = data.aws_subnet_ids.public-subnets.ids
}

module "alb" {
  source = "./alb"
  
  alb_name            = var.alb_name
  alb_subnets         = data.aws_subnet_ids.public-subnets.ids
  vpc                 = data.aws_vpc.jitsi-vpc.id
}

output "alb" {
  value = module.alb
}

module "asg" {
  source = "./asg"

  asg_name               = var.asg_name
  subnets_id             = data.aws_subnet_ids.public-subnets.ids
  desired_capacity       = var.desired_capacity
  min_size               = var.min_size
  max_size               = var.max_size
}

output "asg" {
  value = module.asg
}

module "ecs" {
  source = "./ecs"

  cluster_name           = var.cluster_name
  subnets                = data.aws_subnet_ids.private-subnets.ids
  alb_target_group       = module.alb.alb-tb-arn
  alb_security_group     = module.alb.alb-security-group-id
  vpc                    = data.aws_vpc.jitsi-vpc.id
  ecs-asg                = module.asg.asg-arn
  depends_on = [
    module.alb.alb-tb-arn,module.alb.alb-security-group-id,module.asg.asg-arn
  ]
}

output "ecs" {
  value = module.ecs
}

