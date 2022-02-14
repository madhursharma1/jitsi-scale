resource "aws_ecs_task_definition" "jitsi-web-task" {
  family                   = "jitsi_web"
  container_definitions    = <<DEFINITION
  [
    {
	    "name": "jitsi_web",
	    "image": "nginx:latest",
	    "portMappings": [
        {
			    "containerPort": 80,
			    "hostPort": 80
		    },
		    {
			    "containerPort": 443,
			    "hostPort": 443
		    }
	    ],
	    "memory": 512,
	    "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"   
  memory                   = 512
  cpu                      = 256  
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "jitsi-web-service" {
  name            = "jitsi-web"                   
  cluster         = aws_ecs_cluster.cluster_name.id 
  task_definition = aws_ecs_task_definition.jitsi-web-task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    # target_group_arn = aws_lb_target_group.alb-tb-arn
    target_group_arn = var.alb_target_group
    container_name   = aws_ecs_task_definition.jitsi-web-task.family
    container_port   = 80
  }

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = true
  }
}

resource "aws_security_group" "jitsi-security-group" {
  name          = "jitsi-sg"
  vpc_id        = var.vpc
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    # security_groups = aws_security_group.alb-security-group.id
    security_groups = [var.alb_security_group]
  }

  egress {
    from_port   = 0 
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}