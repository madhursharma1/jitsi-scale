data "aws_ami" "amazon_linux_2" {
most_recent = true
owners = ["amazon"]

  filter {
    name = "name"
    # values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
    values = ["amzn-ami-*-amazon-ecs-optimized"]
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

  ingress {
    from_port   = 80
    to_port     = 80
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

data "template_file" "ecs_instance_userdata" {
  template = file("${path.module}/userdata.sh")

  vars = {
    cluster_name = var.cluster_name
  }
}

resource "aws_launch_configuration" "ecs_launch_config" {
    name_prefix          = join("-", [var.lc_name,""])
    image_id             = data.aws_ami.amazon_linux_2.id
    iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name
    security_groups      = [aws_security_group.asg-security-group.id]
    user_data_base64     = base64encode(data.template_file.ecs_instance_userdata.rendered)
    instance_type        = var.instance_type
    
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "ecs-asg" {
    name                      = var.asg_name
    vpc_zone_identifier       = var.subnets_id
    launch_configuration      = aws_launch_configuration.ecs_launch_config.name

    desired_capacity          = var.desired_capacity
    min_size                  = var.min_size
    max_size                  = var.max_size
    health_check_grace_period = 300
    health_check_type         = "EC2"
    tag {
      key = "Name" 
      value = var.asg_name 
      propagate_at_launch = true
    }
    tag {
      key = "env" 
      value = "dev" 
      propagate_at_launch = true
    }
    tag {
      key = "purpose" 
      value = "jitsi"
      propagate_at_launch = true
    }
}