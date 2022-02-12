resource "aws_ecs_task_definition" "jitsi-web-task" {
  family                   = "jitsi_web"
  container_definitions    = <<DEFINITION
  [
      {
    "name": "jitsi-web",
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
    "cpu": 256,
    "volumes": [
        "${CONFIG}/web:/config:Z",
        "${CONFIG}/transcripts:/usr/share/jitsi-meet/transcripts:Z"
    ],
    "environment": [
        "ENABLE_COLIBRI_WEBSOCKET",
        "ENABLE_FLOC",
        "ENABLE_LETSENCRYPT",
        "ENABLE_HTTP_REDIRECT",
        "ENABLE_HSTS",
        "ENABLE_XMPP_WEBSOCKET",
        "DISABLE_HTTPS",
        "DISABLE_DEEP_LINKING",
        "LETSENCRYPT_DOMAIN",
        "LETSENCRYPT_EMAIL",
        "LETSENCRYPT_USE_STAGING",
        "PUBLIC_URL",
        "TZ",
        "AMPLITUDE_ID",
        "ANALYTICS_SCRIPT_URLS",
        "ANALYTICS_WHITELISTED_EVENTS",
        "CALLSTATS_CUSTOM_SCRIPT_URL",
        "CALLSTATS_ID",
        "CALLSTATS_SECRET",
        "CHROME_EXTENSION_BANNER_JSON",
        "CONFCODE_URL",
        "CONFIG_EXTERNAL_CONNECT",
        "DEFAULT_LANGUAGE",
        "DEPLOYMENTINFO_ENVIRONMENT",
        "DEPLOYMENTINFO_ENVIRONMENT_TYPE",
        "DEPLOYMENTINFO_REGION",
        "DEPLOYMENTINFO_SHARD",
        "DEPLOYMENTINFO_USERREGION",
        "DIALIN_NUMBERS_URL",
        "DIALOUT_AUTH_URL",
        "DIALOUT_CODES_URL",
        "DROPBOX_APPKEY",
        "DROPBOX_REDIRECT_URI",
        "DYNAMIC_BRANDING_URL",
        "ENABLE_AUDIO_PROCESSING",
        "ENABLE_AUTH",
        "ENABLE_CALENDAR",
        "ENABLE_FILE_RECORDING_SERVICE",
        "ENABLE_FILE_RECORDING_SERVICE_SHARING",
        "ENABLE_GUESTS",
        "ENABLE_IPV6",
        "ENABLE_LIPSYNC",
        "ENABLE_NO_AUDIO_DETECTION",
        "ENABLE_P2P",
        "ENABLE_PREJOIN_PAGE",
        "ENABLE_WELCOME_PAGE",
        "ENABLE_CLOSE_PAGE",
        "ENABLE_RECORDING",
        "ENABLE_REMB",
        "ENABLE_REQUIRE_DISPLAY_NAME",
        "ENABLE_SIMULCAST",
        "ENABLE_STATS_ID",
        "ENABLE_STEREO",
        "ENABLE_SUBDOMAINS",
        "ENABLE_TALK_WHILE_MUTED",
        "ENABLE_TCC",
        "ENABLE_TRANSCRIPTIONS",
        "ETHERPAD_PUBLIC_URL",
        "ETHERPAD_URL_BASE",
        "GOOGLE_ANALYTICS_ID",
        "GOOGLE_API_APP_CLIENT_ID",
        "INVITE_SERVICE_URL",
        "JICOFO_AUTH_USER",
        "MATOMO_ENDPOINT",
        "MATOMO_SITE_ID",
        "MICROSOFT_API_APP_CLIENT_ID",
        "NGINX_RESOLVER",
        "NGINX_WORKER_PROCESSES",
        "NGINX_WORKER_CONNECTIONS",
        "PEOPLE_SEARCH_URL",
        "RESOLUTION",
        "RESOLUTION_MIN",
        "RESOLUTION_WIDTH",
        "RESOLUTION_WIDTH_MIN",
        "START_AUDIO_ONLY",
        "START_AUDIO_MUTED",
        "START_WITH_AUDIO_MUTED",
        "START_SILENT",
        "DISABLE_AUDIO_LEVELS",
        "ENABLE_NOISY_MIC_DETECTION",
        "START_BITRATE",
        "DESKTOP_SHARING_FRAMERATE_MIN",
        "DESKTOP_SHARING_FRAMERATE_MAX",
        "START_VIDEO_MUTED",
        "START_WITH_VIDEO_MUTED",
        "TESTING_CAP_SCREENSHARE_BITRATE",
        "TESTING_OCTO_PROBABILITY",
        "XMPP_AUTH_DOMAIN",
        "XMPP_BOSH_URL_BASE",
        "XMPP_DOMAIN",
        "XMPP_GUEST_DOMAIN",
        "XMPP_MUC_DOMAIN",
        "XMPP_RECORDER_DOMAIN",
        "TOKEN_AUTH_URL"
    ]
}
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"   
  memory                   = 512
  cpu                      = 256  
  execution_role_arn       = "aws_iam_role.ecsTaskExecutionRole.arn"
}

resource "aws_ecs_service" "jitsi-web-service" {
  name            = "jitsi-web"                   
  cluster         = "aws_ecs_cluster.cluster_name.id" 
  task_definition = "aws_ecs_task_definition.jitsi-web-task.arn"
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = true
  }
}