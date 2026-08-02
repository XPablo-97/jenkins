# Security Group del Load Balancer (el único que va a estar abierto a internet)
resource "aws_security_group" "alb_sg" {
  name        = "angular-app-alb-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = "vpc-09cbd75b4390f5a97"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "angular-app-alb-sg"
  }
}

# El Load Balancer en si
resource "aws_lb" "angular_app" {
  name               = "angular-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["subnet-09728f3942bb3aa5a", "subnet-0c37a2dd62cefead8"]

  tags = {
    Name = "angular-app-alb"
  }
}

# Target Group: a donde el ALB manda el trafico (las Tasks de ECS)
resource "aws_lb_target_group" "angular_app" {
  name        = "angular-app-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-09cbd75b4390f5a97"
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "angular-app-tg"
    owner = "pablo.duarte@zoi.tech"
  }
}

# Listener: escucha en el puerto 80 y reenvia al Target Group
resource "aws_lb_listener" "angular_app_http" {
  load_balancer_arn = aws_lb.angular_app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.angular_app.arn
  }
}