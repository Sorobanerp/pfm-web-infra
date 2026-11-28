resource "aws_iam_role" "ecs_execution_role" {
  count       = var.compute_engine == "ecs_fargate_spot" ? 1 : 0
  name        = "${var.service_name}-ecs-exec-${var.environment}"
  description = "ECS Task Execution Role for ${var.service_name} (${var.environment})"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  count      = var.compute_engine == "ecs_fargate_spot" ? 1 : 0
  role       = aws_iam_role.ecs_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  count       = var.compute_engine == "ecs_fargate_spot" ? 1 : 0
  name        = "${var.service_name}-ecs-task-${var.environment}"
  description = "Least Privilege Task Role for ${var.service_name} (${var.environment})"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  count             = var.compute_engine == "ecs_fargate_spot" && var.enable_cloudwatch_logs ? 1 : 0
  name              = "/ecs/${var.service_name}-${var.environment}"
  retention_in_days = 7

  tags = {
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_ecs_task_definition" "service" {
  count                    = var.compute_engine == "ecs_fargate_spot" ? 1 : 0
  family                   = "${var.service_name}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_execution_role[0].arn
  task_role_arn            = aws_iam_role.ecs_task_role[0].arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = "${var.image_repository}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          name          = var.port_name
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = var.enable_cloudwatch_logs ? {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs[0].name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "web"
        }
      } : null
      environment = [
        { name = "APP_ENV", value = var.environment },
        { name = "CLOUDWATCH_LOGS_ENABLED", value = "false" },
        { name = "PORT", value = tostring(var.container_port) },
        { name = "DD_SERVICE", value = var.service_name },
        { name = "DD_ENV", value = var.environment },
        { name = "DD_VERSION", value = var.image_tag },
        { name = "DD_LOGS_INJECTION", value = "true" },
        { name = "DD_TRACE_SAMPLE_RATE", value = "0.10" },
        { name = "DD_SITE", value = "us3.datadoghq.com" },
        { name = "OTEL_EXPORTER_OTLP_ENDPOINT", value = "https://otel-collector.pfm.internal:4318" },
        { name = "DD_CREDENTIAL_ARN", value = var.datadog_api_key_secret_arn }
      ]
    }
  ])

  tags = {
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_ecs_service" "service" {
  count           = var.compute_engine == "ecs_fargate_spot" ? 1 : 0
  name            = var.service_name
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.service[0].arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
    base              = 0
  }

  network_configuration {
    subnets          = var.task_subnet_ids
    security_groups  = var.ecs_tasks_security_group_id != "" ? [var.ecs_tasks_security_group_id] : []
    assign_public_ip = true
  }

  dynamic "service_connect_configuration" {
    for_each = var.cloud_map_namespace_arn != "" ? [1] : []
    content {
      enabled   = true
      namespace = var.cloud_map_namespace_arn
      service {
        port_name      = var.port_name
        discovery_name = var.service_name
        client_alias {
          port     = var.container_port
          dns_name = "${var.service_name}.pfm.internal"
        }
      }
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  count              = var.compute_engine == "ecs_fargate_spot" && var.max_capacity > 0 ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.service[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  count              = var.compute_engine == "ecs_fargate_spot" && var.max_capacity > 0 ? 1 : 0
  name               = "${var.service_name}-cpu-autoscaling-${var.environment}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 75.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
