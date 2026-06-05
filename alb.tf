# ─────────────────────────────────────────────
# TIER 1 — External ALB (Internet-facing → Web EC2s)
# ─────────────────────────────────────────────
resource "aws_lb" "external_alb" {
  name               = "${var.project}-external-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
  ]

  tags = {
    Name        = "${var.project}-external-alb"
    environment = var.environment
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "${var.project}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.three_tier_architecture_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.project}-web-tg"
    environment = var.environment
  }
}

resource "aws_lb_target_group_attachment" "web_ec2_1" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_ec2_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_ec2_2" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_ec2_2.id
  port             = 80
}

resource "aws_lb_listener" "external_http" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# ─────────────────────────────────────────────
# TIER 2 — Internal ALB (Web → App EC2s)
# ─────────────────────────────────────────────
resource "aws_lb" "internal_alb" {
  name               = "${var.project}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_alb_sg.id]

  subnets = [
    aws_subnet.private_app_subnet_1.id,
    aws_subnet.private_app_subnet_2.id,
  ]

  tags = {
    Name        = "${var.project}-internal-alb"
    environment = var.environment
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project}-app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.three_tier_architecture_vpc.id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.project}-app-tg"
    environment = var.environment
  }
}

resource "aws_lb_target_group_attachment" "app_ec2_1" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_ec2_1.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "app_ec2_2" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_ec2_2.id
  port             = 8080
}

resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}