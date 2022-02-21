resource "aws_ecs_task_definition" "jitsi-web-task" {
  family                   = "jitsi-web"
  container_definitions    = jsonencode([
  {
    "name": "web-6173-custom",
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
    "memory": 256,
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
resource "aws_ecs_task_definition" "jitsi-prosody-task" {
  family                   = "jitsi-prosody"
  container_definitions    = jsonencode([
  {
    "name": "prosody-6173",
    "image": "ziptech/nlp:prosody-stable-lua",
    "repositoryCredentials": {
            "credentialsParameter": "arn:aws:secretsmanager:ap-south-1:065788519768:secret:docker-private-registry-FsWqdF"
    },
    "portMappings": [
      {
        "containerPort": 5222,
        "hostPort": 5222
      },
      {
        "containerPort": 5347,
        "hostPort": 5347
      },
      {
        "containerPort": 5280,
        "hostPort": 5280
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "jitsi-meet-prosody-config",
        "containerPath": "/config"
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "jitsi-meet-prosody-plugins-custom",
        "containerPath": "/prosody-plugins-custom"
      }
    ],
    "memory": 256,
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
    name           = "jitsi-meet-prosody-config"
    host_path      = "/.jitsi-meet-cfg/prosody/config"
  }
volume {
    name           = "jitsi-meet-prosody-plugins-custom"
    host_path      = "/.jitsi-meet-cfg/prosody/prosody-plugins-custom"
  }
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_task_definition" "jitsi-jicofo-task" {
  family                   = "jitsi-jicofo"
  container_definitions    = jsonencode([
  {
    "name": "jicofo-6173",
    "image": "jitsi/jicofo:stable-6173",
    "repositoryCredentials": {
            "credentialsParameter": "arn:aws:secretsmanager:ap-south-1:065788519768:secret:docker-private-registry-FsWqdF"
    },
    "portMappings": [
      {
        "containerPort": 85,
        "hostPort": 85
      },
    ]
    "mountPoints": [
      {
        "sourceVolume": "jitsi-meet-jicofo",
        "containerPath": "/config"
      }
    ],
    "memory": 256,
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
    name           = "jitsi-meet-jicofo"
    host_path      = "/.jitsi-meet-cfg/jicofo"
  }
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "jitsi-web-service" {
  name            = "web-6173-custom"                   
  cluster         = aws_ecs_cluster.cluster_name.id 
  task_definition = aws_ecs_task_definition.jitsi-web-task.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = var.alb_target_group
    container_name   = "web-6173-custom"
    container_port   = 80
  }
}

resource "aws_ecs_service" "jitsi-prosody-service" {
  name            = "prosody-6173"                   
  cluster         = aws_ecs_cluster.cluster_name.id 
  task_definition = aws_ecs_task_definition.jitsi-prosody-task.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = var.alb_target_group
    container_name   = "prosody-6173"
    container_port   = 5222
  }
}

resource "aws_ecs_service" "jitsi-jicofo-service" {
  name            = "jicofo-6173"                   
  cluster         = aws_ecs_cluster.cluster_name.id 
  task_definition = aws_ecs_task_definition.jitsi-jicofo-task.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = var.alb_target_group
    container_name   = "jicofo-6173"
    container_port   = 85
  }
}
  # network_configuration {
  #   subnets          = var.subnets
  # }

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