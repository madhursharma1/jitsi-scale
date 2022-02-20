resource "aws_ecs_task_definition" "jitsi-web-task" {
  family                   = "jitsi-web"
  container_definitions    = jsonencode([
  {
    "name": "jitsi-web",
    "image": "ziptech/nlp:jitsi-web-custom-v2.0.0",
    "repositoryCredentials": {
            "credentialsParameter": "arn:aws:secretsmanager:ap-south-1:065788519768:secret:docker-private-registry-FsWqdF"
    },
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
    "mountPoints": [
      {
        "sourceVolume": "jitsi-meet-transcripts",
        "containerPath": "/usr/share/jitsi-meet/transcripts"
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "jitsi-meet-web",
        "containerPath": "/config"
      }
    ],
    "essential": true,
    "memory": 512,
    "cpu": 256,
    "environmentFiles": [
        {
          "value": "arn:aws:s3:::dev-zipteams-infra/jitsi-ecs-env/.env",
          "type": "s3"
        }
    ]
  }
])
volume {
    name           = "jitsi-meet-web"
    host_path      = "/.jitsi-meet-cfg/web"
  }
volume {
    name           = "jitsi-meet-transcript"
    host_path      = "/.jitsi-meet-cfg/transcripts"
  } 
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "jitsi-web-service" {
  name            = "jitsi-web"                   
  cluster         = aws_ecs_cluster.cluster_name.id 
  task_definition = aws_ecs_task_definition.jitsi-web-task.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = var.alb_target_group
    container_name   = aws_ecs_task_definition.jitsi-web-task.family
    container_port   = 80
  }

  # network_configuration {
  #   subnets          = var.subnets
  # }
}

resource "aws_security_group" "jitsi-security-group" {
  name          = "jitsi-sg"
  vpc_id        = var.vpc
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [var.alb_security_group]
  }

  egress {
    from_port   = 0 
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}