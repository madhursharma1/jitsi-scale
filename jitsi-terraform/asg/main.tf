data "aws_ami" "amazon_linux_2" {
most_recent = true
owners = ["amazon"]

filter {
name = "name"
values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
}
}

resource "aws_security_group" "asg-security-group" {
  name          = join("-", [var.asg_name, "sg"])
  vpc_id        = "vpc-080a047018a9d9e8d"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  egress {
    from_port   = 0 
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "ecs_launch_config" {
    name                 = "jitsi-lc"
    image_id             = "data.aws_ami.amazon_linux_2"
    iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name
    security_groups      = [aws_security_group.asg-security-group.id]
    instance_type        = "m5.large"
}

resource "aws_autoscaling_group" "ecs-asg" {
    name                      = "jitsi-asg"
    vpc_zone_identifier       = var.subnets_id
    launch_configuration      = aws_launch_configuration.ecs_launch_config.name

    desired_capacity          = var.desired_capacity
    min_size                  = var.min_size
    max_size                  = var.max_size
    health_check_grace_period = 300
    health_check_type         = "EC2"
}