# ============================================================================
# ECS Cluster and Service Module
# ============================================================================

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-n8n-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-cluster"
  })
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.environment}-n8n-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-alb"
  })
}

# Target Group
resource "aws_lb_target_group" "main" {
  name        = "${var.environment}-n8n-tg"
  port        = 5678
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 120
    path                = "/"
    matcher             = "200,302"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-target-group"
  })
}

# ALB Listener (HTTP)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ALB Listener (HTTPS) - conditional on certificate
resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# If no HTTPS certificate, use HTTP
resource "aws_lb_listener" "http_direct" {
  count             = var.certificate_arn == "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "n8n" {
  name              = "/ecs/${var.environment}-n8n"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-logs"
  })
}

# ECS Task Definition
resource "aws_ecs_task_definition" "n8n" {
  family                   = "${var.environment}-n8n"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.n8n_cpu
  memory                   = var.n8n_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name  = "n8n"
      image = var.n8n_image

      portMappings = [
        {
          containerPort = 5678
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "N8N_PROTOCOL"
          value = var.certificate_arn != "" ? "https" : "http"
        },
        {
          name  = "N8N_HOST"
          value = var.n8n_domain_name != "" ? var.n8n_domain_name : aws_lb.main.dns_name
        },
        {
          name  = "N8N_PORT"
          value = "5678"
        },
        {
          name  = "WEBHOOK_URL"
          value = var.certificate_arn != "" ? "https://${var.n8n_domain_name != "" ? var.n8n_domain_name : aws_lb.main.dns_name}" : "http://${aws_lb.main.dns_name}"
        },
        {
          name  = "DB_TYPE"
          value = "postgresdb"
        },
        {
          name  = "DB_POSTGRESDB_HOST"
          value = var.db_host
        },
        {
          name  = "DB_POSTGRESDB_PORT"
          value = "5432"
        },
        {
          name  = "DB_POSTGRESDB_DATABASE"
          value = var.db_name
        },
        {
          name  = "DB_POSTGRESDB_USER"
          value = var.db_username
        },
        {
          name  = "N8N_METRICS"
          value = "true"
        },
        {
          name  = "DB_POSTGRESDB_POOL_SIZE"
          value = "2"
        },
        {
          name  = "N8N_LOG_LEVEL"
          value = "warn"
        },
        {
          name  = "EXECUTIONS_PROCESS"
          value = "main"
        }
      ]

      secrets = [
        {
          name      = "DB_POSTGRESDB_PASSWORD"
          valueFrom = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:n8n/${var.environment}/database-credentials:password::"
        },
        {
          name      = "N8N_ENCRYPTION_KEY"
          valueFrom = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:n8n/${var.environment}/encryption-key:encryption_key::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.n8n.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:5678/ || exit 1"
        ]
        interval    = 30
        timeout     = 5
        retries     = 5
        startPeriod = 120
      }

      essential = true
    }
  ])

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-task-definition"
  })
}

# ECS Service
resource "aws_ecs_service" "n8n" {
  name            = "${var.environment}-n8n-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.n8n.arn
  launch_type     = "FARGATE"
  desired_count   = var.n8n_desired_count

  network_configuration {
    security_groups  = [var.ecs_security_group_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = true # Required for Fargate tasks to pull images
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "n8n"
    container_port   = 5678
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # Wait for at least one task to be healthy before considering deployment successful
  wait_for_steady_state = true

  depends_on = [
    aws_lb_listener.http
  ]

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-service"
  })
}