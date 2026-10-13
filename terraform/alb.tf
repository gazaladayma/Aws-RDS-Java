# Existing internet-facing Application Load Balancer.
resource "aws_lb" "java_app" {
  name               = "java-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = 60

  drop_invalid_header_fields       = false
  preserve_host_header             = false
  enable_cross_zone_load_balancing = true

  access_logs {
    bucket  = "gazaldevops-java-logs-2026"
    enabled = true
  }

  tags = {}
}

# Existing target group used by the Java application instances.
resource "aws_lb_target_group" "java_app" {
  name        = "java-app-target-group"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.java_app.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/LoginWebApp/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {}
}

# Existing HTTP listener: redirect all traffic to HTTPS.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.java_app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

# Existing HTTPS listener: forward traffic to the Java application.
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.java_app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
  certificate_arn   = "arn:aws:acm:us-east-1:820242917252:certificate/71e324d4-84d2-4407-8111-5ee9f0a0e414"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.java_app.arn

    forward {
      target_group {
        arn    = aws_lb_target_group.java_app.arn
        weight = 1
      }

      stickiness {
        enabled  = false
        duration = 3600
      }
    }
  }
}
