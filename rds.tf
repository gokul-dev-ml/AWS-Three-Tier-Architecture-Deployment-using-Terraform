# ─────────────────────────────────────────────
# TIER 3 — RDS Subnet Group
# ─────────────────────────────────────────────
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_db_subnet_1.id,
    aws_subnet.private_db_subnet_2.id,
  ]

  tags = {
    Name        = "${var.project}-db-subnet-group"
    environment = var.environment
  }
}

# ─────────────────────────────────────────────
# TIER 3 — RDS MySQL (Multi-AZ for HA)
# ─────────────────────────────────────────────
resource "aws_db_instance" "mysql" {
  identifier              = "${var.project}-mysql"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp3"
  storage_encrypted       = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  multi_az               = var.environment == "prod" ? true : false
  publicly_accessible    = false
  skip_final_snapshot    = var.environment == "prod" ? false : true
  final_snapshot_identifier = var.environment == "prod" ? "${var.project}-final-snapshot" : null

  backup_retention_period = var.environment == "prod" ? 7 : 1
  deletion_protection     = var.environment == "prod" ? true : false

  tags = {
    Name        = "${var.project}-mysql"
    environment = var.environment
    Tier        = "Database"
  }
}