resource "aws_security_group" "security-group" {
  name          = var.alb_name-sg
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0 
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "jitsi-alb" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets = var.alb_subnets
  security_groups = [aws_security_group.security-group.id]
}

resource "aws_lb_target_group" "alb-tb" {
  name        = var.alb_name-tb
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc
  health_check {
    matcher = "200,301,302"
    path = "/"
  }
}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.jitsi-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tb.arn
  }
}