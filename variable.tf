variable "project" {
  type        = string
  default     = "three-tier"
  description = "The name of the project. Used as a prefix for all resource names."
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "The deployment environment (dev, staging, prod). Controls Multi-AZ, deletion protection, etc."
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "key_name" {
  type        = string
  default     = "singaporekey"
  description = "Name of the EC2 key pair used for SSH access via Bastion."
}

variable "admin_ip" {
  type        = string
  default     = "110.224.84.220/32"
  description = "Admin IP CIDR allowed to SSH into the Bastion host."
}

# ─── EC2 Instance Types ───────────────────────
variable "web_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type for the Web Tier."
}

variable "app_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type for the App Tier."
}

# ─── RDS / Database ───────────────────────────
variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class for the Database Tier."
}

variable "db_name" {
  type        = string
  default     = "appdb"
  description = "Name of the initial database to create in RDS."
}

variable "db_username" {
  type        = string
  default     = "admin"
  description = "Master username for the RDS instance."
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "Master password for the RDS instance. Pass via TF_VAR_db_password or a secrets manager."
  sensitive   = true
}