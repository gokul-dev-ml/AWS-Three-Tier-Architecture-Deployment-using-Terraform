# ─────────────────────────────────────────────
# Outputs
# ─────────────────────────────────────────────

output "external_alb_dns" {
  description = "Public DNS of the External ALB (Web Tier entry point)"
  value       = aws_lb.external_alb.dns_name
}

output "internal_alb_dns" {
  description = "Internal DNS of the Internal ALB (App Tier entry point)"
  value       = aws_lb.internal_alb.dns_name
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = aws_instance.bastion.public_ip
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint (Database Tier)"
  value       = aws_db_instance.mysql.endpoint
  sensitive   = true
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.three_tier_architecture_vpc.id
}