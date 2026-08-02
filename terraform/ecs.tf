# Cluster ECS (el "grupo lógico" donde van a vivir los contenedores)
resource "aws_ecs_cluster" "main" {
  name = "angular-app-cluster"

  tags = {
    Name = "angular-app-cluster"
    owner = "pablo.duarte@zoi.tech"
  }
}

# Rol IAM que usa ECS/Fargate para poder:
# - Descargar la imagen desde ECR
# - Escribir logs a CloudWatch
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

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

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Donde van a aparecer los logs del contenedor (como "docker logs", pero en AWS)
resource "aws_cloudwatch_log_group" "angular_app" {
  name              = "/ecs/angular-app"
  retention_in_days = 7
}

# Security Group para el servicio ECS (el "firewall" del contenedor)
resource "aws_security_group" "ecs_service_sg" {
  name        = "angular-app-ecs-sg"
  description = "Security group for the Angular app running on ECS Fargate"
  vpc_id      = "vpc-09cbd75b4390f5a97"

  ingress {
    description = "HTTP desde el ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "angular-app-ecs-sg"
  }
}

# Task Definition (la "receta" del contenedor)
resource "aws_ecs_task_definition" "angular_app" {
  family                   = "angular-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "angular-app"
      image = "${aws_ecr_repository.angular_app.repository_url}:latest"

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.angular_app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "angular_app" {
  name            = "angular-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.angular_app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-09728f3942bb3aa5a"]
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.angular_app.arn
    container_name    = "angular-app"
    container_port    = 80
  }

  depends_on = [aws_lb_listener.angular_app_http]
}
