# 
# Bastion Host SG (SSH from admin IP only)
# 
resource "aws_security_group" "bastion_sg" {
  name        = "${var.project}-bastion-sg"
  description = "Security Group for Bastion Host - SSH from admin IP only"
  vpc_id      = aws_vpc.three_tier_architecture_vpc.id

  ingress {
    description = "SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-bastion-sg"
    environment = var.environment
  }
}

# 
# TIER 1 - External ALB SG (HTTP/HTTPS from internet)
# 
resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-alb-sg"
  description = "Security Group for External ALB - Web Tier"
  vpc_id      = aws_vpc.three_tier_architecture_vpc.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
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
    Name        = "${var.project}-alb-sg"
    environment = var.environment
  }
}

# 
# TIER 1 - Web EC2 SG (HTTP from external ALB + SSH from Bastion)
# 
resource "aws_security_group" "web_sg" {
  name        = "${var.project}-web-sg"
  description = "Security Group for Web Tier EC2 instances"
  vpc_id      = aws_vpc.three_tier_architecture_vpc.id

  ingress {
    description     = "HTTP from External ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-web-sg"
    environment = var.environment
  }
}

# 
# TIER 2 - Internal ALB SG (from Web EC2)
# 
resource "aws_security_group" "internal_alb_sg" {
  name        = "${var.project}-internal-alb-sg"
  description = "Security Group for Internal ALB - App Tier"
  vpc_id      = aws_vpc.three_tier_architecture_vpc.id

  ingress {
    description     = "HTTP from Web Tier"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-internal-alb-sg"
    environment = var.environment
  }
}

# 
# TIER 2 - App EC2 SG (from internal ALB + SSH from Bastion)
# 
resource "aws_security_group" "app_sg" {
  name        = "${var.project}-app-sg"
  description = "Security Group for App Tier EC2 instances"
  vpc_id      = aws_vpc.three_tier_architecture_vpc.id

  ingress {
    description     = "HTTP from Internal ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb_sg.id]
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-app-sg"
    environment = var.environment
  }
}

# 
# TIER 3 - RDS SG (MySQL/Postgres from App Tier only)
# 
resource "aws_security_group" "db_sg" {
  name        = "${var.project}-db-sg"
  description = "Security Group for Database Tier (RDS)"
  vpc_id      = aws_vpc.three_tier_architecture_vpc.id

  ingress {
    description     = "MySQL from App Tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-db-sg"
    environment = var.environment
  }
}