locals {
  ubuntu_ami = "resolve:ssm:/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

# ─────────────────────────────────────────────
# Bastion Host (public subnet — jump box only)
# ─────────────────────────────────────────────
resource "aws_instance" "bastion" {
  ami                         = local.ubuntu_ami
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name        = "${var.project}-bastion"
    managed_by  = var.environment
    Tier        = "Bastion"
  }
}

# ─────────────────────────────────────────────
# TIER 1 — Web EC2s (public subnets, behind external ALB)
# ─────────────────────────────────────────────
resource "aws_instance" "web_ec2_1" {
  ami                         = local.ubuntu_ami
  instance_type               = var.web_instance_type
  subnet_id                   = aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name        = "${var.project}-web-ec2-1"
    managed_by  = var.environment
    Tier        = "Web"
  }
}

resource "aws_instance" "web_ec2_2" {
  ami                         = local.ubuntu_ami
  instance_type               = var.web_instance_type
  subnet_id                   = aws_subnet.public_subnet_2.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name        = "${var.project}-web-ec2-2"
    managed_by  = var.environment
    Tier        = "Web"
  }
}

# ─────────────────────────────────────────────
# TIER 2 — App EC2s (private subnets, behind internal ALB)
# ─────────────────────────────────────────────
resource "aws_instance" "app_ec2_1" {
  ami                         = local.ubuntu_ami
  instance_type               = var.app_instance_type
  subnet_id                   = aws_subnet.private_app_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = false
  key_name                    = var.key_name

  tags = {
    Name        = "${var.project}-app-ec2-1"
    managed_by  = var.environment
    Tier        = "App"
  }
}

resource "aws_instance" "app_ec2_2" {
  ami                         = local.ubuntu_ami
  instance_type               = var.app_instance_type
  subnet_id                   = aws_subnet.private_app_subnet_2.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = false
  key_name                    = var.key_name

  tags = {
    Name        = "${var.project}-app-ec2-2"
    managed_by  = var.environment
    Tier        = "App"
  }
}