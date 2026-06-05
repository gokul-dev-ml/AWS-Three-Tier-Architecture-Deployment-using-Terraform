# ─────────────────────────────────────────────
# VPC
# ─────────────────────────────────────────────
resource "aws_vpc" "three_tier_architecture_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project}-vpc"
    environment = var.environment
  }
}

# ─────────────────────────────────────────────
# TIER 1 — Public Subnets (Web / ALB layer)
# ─────────────────────────────────────────────
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.three_tier_architecture_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-public-subnet-1"
    environment = var.environment
    Tier        = "Web"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.three_tier_architecture_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-public-subnet-2"
    environment = var.environment
    Tier        = "Web"
  }
}

# ─────────────────────────────────────────────
# TIER 2 — Private Subnets (App layer)
# ─────────────────────────────────────────────
resource "aws_subnet" "private_app_subnet_1" {
  vpc_id            = aws_vpc.three_tier_architecture_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name        = "${var.project}-private-app-subnet-1"
    environment = var.environment
    Tier        = "App"
  }
}

resource "aws_subnet" "private_app_subnet_2" {
  vpc_id            = aws_vpc.three_tier_architecture_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name        = "${var.project}-private-app-subnet-2"
    environment = var.environment
    Tier        = "App"
  }
}

# ─────────────────────────────────────────────
# TIER 3 — Private Subnets (Database layer)
# ─────────────────────────────────────────────
resource "aws_subnet" "private_db_subnet_1" {
  vpc_id            = aws_vpc.three_tier_architecture_vpc.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name        = "${var.project}-private-db-subnet-1"
    environment = var.environment
    Tier        = "Database"
  }
}

resource "aws_subnet" "private_db_subnet_2" {
  vpc_id            = aws_vpc.three_tier_architecture_vpc.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name        = "${var.project}-private-db-subnet-2"
    environment = var.environment
    Tier        = "Database"
  }
}

# ─────────────────────────────────────────────
# Internet Gateway
# ─────────────────────────────────────────────
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.three_tier_architecture_vpc.id

  tags = {
    Name        = "${var.project}-igw"
    environment = var.environment
  }
}

# ─────────────────────────────────────────────
# NAT Gateway (in public subnet 1 for HA use subnet 2 as well if needed)
# ─────────────────────────────────────────────
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.project}-nat-eip"
    environment = var.environment
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name        = "${var.project}-nat-gateway"
    environment = var.environment
  }

  depends_on = [aws_internet_gateway.igw]
}

# ─────────────────────────────────────────────
# Route Table — Public (via IGW)
# ─────────────────────────────────────────────
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.three_tier_architecture_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.project}-public-rt"
    environment = var.environment
  }
}

resource "aws_route_table_association" "public_rta_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# ─────────────────────────────────────────────
# Route Table — Private App (via NAT)
# ─────────────────────────────────────────────
resource "aws_route_table" "private_app_rt" {
  vpc_id = aws_vpc.three_tier_architecture_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name        = "${var.project}-private-app-rt"
    environment = var.environment
  }
}

resource "aws_route_table_association" "private_app_rta_1" {
  subnet_id      = aws_subnet.private_app_subnet_1.id
  route_table_id = aws_route_table.private_app_rt.id
}

resource "aws_route_table_association" "private_app_rta_2" {
  subnet_id      = aws_subnet.private_app_subnet_2.id
  route_table_id = aws_route_table.private_app_rt.id
}

# ─────────────────────────────────────────────
# Route Table — Private DB (no internet)
# ─────────────────────────────────────────────
resource "aws_route_table" "private_db_rt" {
  vpc_id = aws_vpc.three_tier_architecture_vpc.id

  tags = {
    Name        = "${var.project}-private-db-rt"
    environment = var.environment
  }
}

resource "aws_route_table_association" "private_db_rta_1" {
  subnet_id      = aws_subnet.private_db_subnet_1.id
  route_table_id = aws_route_table.private_db_rt.id
}

resource "aws_route_table_association" "private_db_rta_2" {
  subnet_id      = aws_subnet.private_db_subnet_2.id
  route_table_id = aws_route_table.private_db_rt.id
}