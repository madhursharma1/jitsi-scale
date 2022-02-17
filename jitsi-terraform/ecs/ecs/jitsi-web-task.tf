resource "aws_ecs_task_definition" "jitsi-web-task" {
  family                   = "jitsi_web"
  container_definitions    = <<DEFINITION
[
  {
    "name": "jitsi-web",
    "image": "ziptech/nlp:jitsi-web-custom-v2.0.0",
    "repositoryCredentials": {
            "credentialsParameter": "arn:aws:secretsmanager:ap-south-1:065788519768:secret:docker-private-registry-FsWqdF"
    },
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 8080
      },
      {
        "containerPort": 443,
        "hostPort": 8443
      }
    ],
    "memory": 512,
    "cpu": 256,
    "environment": [
      {
        "name": "test",
        "value": "2"
      }
    ]
  }
]
  DEFINITION
  network_mode             = "host"   
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "jitsi-web-service" {
  name            = "jitsi-web"                   
  cluster         = aws_ecs_cluster.cluster_name.id 
  task_definition = aws_ecs_task_definition.jitsi-web-task.arn
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